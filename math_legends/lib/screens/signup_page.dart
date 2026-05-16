import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_legends/configs/background_img.dart';
import 'package:math_legends/configs/buttons.dart';
import 'package:math_legends/configs/regex.dart';
import 'package:math_legends/configs/text_stroke.dart';
import 'package:math_legends/controllers/signup_controller.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    var signupController = Get.put(SignupController());

    return BackgroundImgConfig(
        child: SingleChildScrollView(
      padding: const EdgeInsets.only(top: 15, bottom: 15),
      child: Form(
        key: signupController.formKey,
        autovalidateMode: AutovalidateMode.always,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            width: 250,
            height: 250,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/math_legends_logo.png'),
                    fit: BoxFit.cover)),
          ),
          CustomTextField(
              controller: signupController.nameController,
              validate: true,
              hintText: 'Name',
              textInputType: TextInputType.name,
              regExp: RegexConfigValues.nameRegex,
              icon: Icons.person_rounded,
              gradientColors: const [Color(0xFF3FA7D6), Color(0xFF1C6FB8)],
              borderColor: const Color(0xFFBEE7FF),
              iconColor: Colors.yellowAccent[700]!),
          const SizedBox(
            height: 10,
          ),
          CustomTextField(
              controller: signupController.emailController,
              validate: true,
              hintText: 'Email',
              textInputType: TextInputType.emailAddress,
              regExp: RegexConfigValues.emailRegex,
              icon: Icons.email_rounded,
              gradientColors: const [Color(0xFF3FA7D6), Color(0xFF1C6FB8)],
              borderColor: const Color(0xFFBEE7FF),
              iconColor: Colors.yellowAccent[700]!),
          const SizedBox(
            height: 10,
          ),
          CustomTextField(
            controller: signupController.passwordController,
            validate: true,
            hintText: 'Password',
            textInputType: TextInputType.visiblePassword,
            regExp: RegexConfigValues.passwordRegex,
            icon: Icons.lock_rounded,
            gradientColors: const [Color(0xFF3FA7D6), Color(0xFF1C6FB8)],
            borderColor: const Color(0xFFBEE7FF),
            iconColor: Colors.yellowAccent[700]!,
            obscureText: true,
          ),
          const SizedBox(
            height: 10,
          ),
          CustomTextField(
            controller: signupController.cfmPasswordController,
            validate: true,
            hintText: 'Confirm Password',
            textInputType: TextInputType.visiblePassword,
            regExp: RegexConfigValues.passwordRegex,
            icon: Icons.lock_rounded,
            gradientColors: const [Color(0xFF3FA7D6), Color(0xFF1C6FB8)],
            borderColor: const Color(0xFFBEE7FF),
            iconColor: Colors.yellowAccent[700]!,
            obscureText: true,
          ),
          const SizedBox(
            height: 20,
          ),
          CustomButton(
              btnWidth: 200,
              onPressed: () async {
                await signupController.signup();
              },
              gradientColors: [
                Colors.yellowAccent[200]!,
                Colors.yellowAccent[700]!
              ],
              borderColor: Colors.yellowAccent,
              textStrokeColor: Colors.yellow[900]!,
              text: 'Sign up'),
          const SizedBox(
            height: 45,
          ),
          StrokeText(
            'Already have account?',
            fontSize: 25,
            fillColor: Colors.white,
            strokeColor: Colors.purple[900]!,
            strokeWidth: 5,
          ),
          const SizedBox(
            height: 10,
          ),
          CustomButton(
              btnWidth: 200,
              onPressed: () => signupController.goToLogin(),
              gradientColors: [
                Colors.purpleAccent[200]!,
                Colors.purpleAccent[700]!
              ],
              borderColor: Colors.purple[100]!,
              textStrokeColor: Colors.purple[900]!,
              text: 'Log in'),
        ]),
      ),
    ));
  }
}
