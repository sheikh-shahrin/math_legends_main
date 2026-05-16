import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:math_legends/configs/popup.dart';

class FirebaseAuthService {
  final FirebaseAuth _fbAuth = FirebaseAuth.instance;

  Future<User?> signIn({String? email, String? password}) async {
    try {
      UserCredential ucred = await _fbAuth.signInWithEmailAndPassword(
          email: email!, password: password!);
      User? user = ucred.user;
      debugPrint(
          "Signed In successful! userid: ${ucred.user?.uid}, user: $user");
      return user!;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      if (e.code == 'invalid-credential') {
        PopupConfig.showOkPopup('Error', 'Email or password is incorrect');
      } else if (e.code == 'invalid-email') {
        PopupConfig.showOkPopup('Error', 'Email is invalid');
      } else if (e.code == 'user-disabled') {
        PopupConfig.showOkPopup('Error', 'User account is disabled');
      } else {
        PopupConfig.showOkPopup('Error', e.message!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<User?> signUp({String? email, String? password}) async {
    try {
      UserCredential ucred = await _fbAuth.createUserWithEmailAndPassword(
          email: email!, password: password!);
      User? user = ucred.user;
      debugPrint("Signed Up successful! user: $user");
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
      DoNothingAction();
      if (e.code == 'email-already-in-use') {
        PopupConfig.showOkPopup('Error',
            'User already exist.\nPlease Log In to access your account.');
      } else if (e.code == 'invalid-email') {
        PopupConfig.showOkPopup('Error', 'Email is invalid');
      } else {
        PopupConfig.showOkPopup('Error', e.message!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _fbAuth.signOut();
  }
}
