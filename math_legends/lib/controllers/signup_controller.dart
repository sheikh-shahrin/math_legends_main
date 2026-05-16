import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_legends/services/firebaseauth_service.dart';
import 'package:math_legends/configs/login.dart';
import 'package:math_legends/configs/popup.dart';
import 'package:math_legends/models/user_model.dart';
import 'package:math_legends/screens/home_page.dart';
import 'package:math_legends/screens/login_page.dart';
import 'package:math_legends/services/firestore_user_service.dart';

import 'user_controller.dart';

class SignupController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cfmPasswordController = TextEditingController();

  final isLoading = false.obs; // Tracks if the signup process is running

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    cfmPasswordController.dispose();
    super.dispose();
  }

  void _clearFormInputs() {
    formKey.currentState!.reset();
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    cfmPasswordController.clear();
  }

  Future<void> signup() async {
    if (isLoading.value) return;

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        cfmPasswordController.text.isEmpty) {
      PopupConfig.showOkPopup('Error', 'One or more fields are empty!');
    } else if (formKey.currentState!.validate()) {
      if (passwordController.text == cfmPasswordController.text) {
        try {
          isLoading.value = true;

          var nameTrim = nameController.text.trim();
          var emailTrim = emailController.text.trim();
          var passTrim = passwordController.text.trim();

          var newUser = await FirebaseAuthService()
              .signUp(email: emailTrim, password: passTrim);

          if (newUser != null) {
            await FirestoreUserService().addUserData(User.fromMap({
              'uid': newUser.uid,
              'name': nameTrim,
              'email': emailTrim,
              'xp': 0.00,
              'rp': 0.00,
              'coins': 0,
              'profilePic': null,
              'playStats': {'chapter': 1, 'stage': 1},
              'petStats': Pet().toMap()
            }));

            final User? userModel =
                await FirestoreUserService().getUserByUid(newUser.uid);

            if (userModel != null) {
              _clearFormInputs();
              await LoginSession.createSession(newUser.uid);

              final userCtrl = Get.put(UserController(), permanent: true);
              await userCtrl.loadUser(newUser.uid);

              Get.off(() => HomePage(
                    uid: newUser.uid,
                    newUser: true,
                  ));
            }
          }
        } catch (e) {
          PopupConfig.showOkPopup('Error', 'An unexpected error occurred.');
        } finally {
          isLoading.value = false; // Stop loading regardless of success or fail
        }
      } else {
        PopupConfig.showOkPopup('Error', 'Passwords does not match!');
      }
    } else {
      PopupConfig.showOkPopup('Error', 'One or more fields are invalid!');
    }
  }

  void goToLogin() {
    _clearFormInputs();
    Get.off(() => const LoginPage());
  }
}
