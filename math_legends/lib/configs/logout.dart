import 'package:get/get.dart';
import 'package:math_legends/screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/settings_controller.dart';
import '../controllers/user_controller.dart';

class LogoutSession {
  static Future<void> endSession() async {
    SharedPreferences? sp = await SharedPreferences.getInstance();
    sp.clear();

    if (Get.isRegistered<SettingsController>()) {
      Get.find<SettingsController>().resetSettings();
      Get.delete<SettingsController>();
    }

    if (Get.isRegistered<UserController>()) {
      Get.find<UserController>().clearUser();
      Get.delete<UserController>();
    }

    Get.offAll(() => const LoginPage());
  }
}
