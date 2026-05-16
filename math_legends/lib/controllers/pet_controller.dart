import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/firestore_user_service.dart';
import '../services/sound_service.dart';
import '../utils/game_data.dart';

class PetController extends GetxController {
  final user = Rx<User?>(null);
  final firestore = FirestoreUserService();
  final posX = 20.0.obs;
  final posY = 120.0.obs;

  void setUser(User u) {
    user.value = u;
  }

  /// BUY PET
  Future<void> buyPet(PetData pet, BuildContext context) async {
    final u = user.value!;
    if (u.coins! < pet.cost) {
      if (Get.isSnackbarOpen) return;

      SoundService.playSfx('sounds/error_sound.mp3');

      Get.rawSnackbar(
        borderRadius: 30,
        maxWidth: MediaQuery.of(context).size.width * .55,
        margin: const EdgeInsets.only(top: 15),
        messageText: const Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Not enough coins!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      return;
    }

    SoundService.playSfx('sounds/purchase.mp3');

    final stats = u.petData!.petData![pet]!;
    if (stats.discovered == true) return;

    u.coins = u.coins! - pet.cost;
    stats.discovered = true;

    await firestore.updateUser(u);
    user.refresh();
  }

  /// EQUIP PET (only ONE allowed)
  Future<void> equipPet(PetData pet) async {
    final u = user.value!;

    for (final entry in u.petData!.petData!.entries) {
      entry.value.equipped = false;
    }

    u.petData!.petData![pet]!.equipped = true;

    await firestore.updateUser(u);
    user.refresh();
  }

  void updatePosition(Offset offset, Size screenSize) {
    const petSize = 80.0;

    double x = offset.dx;
    double y = offset.dy;

    // Clamp to screen bounds
    x = x.clamp(0, screenSize.width - petSize);
    y = y.clamp(0, screenSize.height - petSize);

    posX.value = x;
    posY.value = y;
  }

  Future<void> updateUserStats(String uid) async {
    user.value = await firestore.getUserByUid(uid);
  }

  PetData? get equippedPet {
    final u = user.value;
    if (u == null || u.petData?.petData == null) return null;

    // firstWhereOrNull returns null safely if no pet is equipped
    final entry = u.petData!.petData!.entries
        .firstWhereOrNull((e) => e.value.equipped == true);

    return entry?.key;
  }

  double get coinMultiplier {
    final pet = equippedPet;
    return pet?.multiplier ?? 1.0;
  }
}
