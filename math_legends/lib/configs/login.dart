import 'package:shared_preferences/shared_preferences.dart';

class LoginSession {
  static Future<void> createSession(String uid) async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    if (uid != '') {
      await sp.setString('uid', uid);
    }
  }
}
