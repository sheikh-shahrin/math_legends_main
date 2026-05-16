import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_legends/controllers/user_controller.dart';
import 'package:math_legends/services/firebaseauth_service.dart';
import 'package:math_legends/configs/login.dart';
import 'package:math_legends/configs/popup.dart';
import 'package:math_legends/models/user_model.dart';
import 'package:math_legends/screens/home_page.dart';
import 'package:math_legends/screens/signup_page.dart';
import 'package:math_legends/services/firestore_user_service.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _clearFormInputs() {
    formKey.currentState!.reset();
    emailController.clear();
    passwordController.clear();
  }

  Future<void> login(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      PopupConfig.showOkPopup('Error', 'One or more fields are empty!');
    } else if (formKey.currentState!.validate()) {
      var emailTrim = emailController.text.trim();
      var passTrim = passwordController.text.trim();

      var loginUser = await FirebaseAuthService()
          .signIn(email: emailTrim, password: passTrim);


      if (loginUser != null) {
        User? userModel =
            await FirestoreUserService().getUserByUid(loginUser.uid);

        if (userModel != null) {
          _clearFormInputs();
          await LoginSession.createSession(loginUser.uid);
          
          final userCtrl = Get.put(UserController(), permanent: true);
          await userCtrl.loadUser(loginUser.uid);
          
          Get.off(() => HomePage(
                uid: loginUser.uid,
                newUser: false,
              ));
        }
      }
    } else {
      PopupConfig.showOkPopup('Error', 'One or more fields are invalid!');
    }
  }

  void goToSignup() {
    _clearFormInputs();
    Get.off(() => const SignupPage());
  }
}
