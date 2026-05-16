import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/user_controller.dart';

class RetrieveUserdata {
  Future<String?> retrieveUid() async {
    SharedPreferences? sp = await SharedPreferences.getInstance();
    String? uid = sp.getString('uid');

    if (uid != null) {
      final userCtrl = Get.put(UserController(), permanent: true);
      await userCtrl.loadUser(uid);

      return uid;
    }

    return null;
  }
}
