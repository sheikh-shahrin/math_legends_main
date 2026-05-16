import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:math_legends/controllers/pet_controller.dart';
import 'package:math_legends/models/user_model.dart';

import '../services/firestore_user_service.dart';

class UserController extends GetxController {
  final Rxn<User> user = Rxn<User>();
  final _firestore = FirestoreUserService();

  Future<void> loadUser(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (doc.exists) {
      final petCtrl = Get.put(PetController(), permanent: true);

      user.value = User.fromMap(doc.data()!);
      petCtrl.setUser(user.value!);
    }
  }

  void updateLocal(User updated) {
    user.value = updated;
  }

  void clearUser() {
    user.value = null;
  }

  Future<void> reloadUser() async {
    if (user.value?.uid == null) return;

    final freshUser = await _firestore.getUserByUid(user.value!.uid!);
    user.value = freshUser;
  }
}
