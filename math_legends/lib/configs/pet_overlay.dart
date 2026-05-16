import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pet_controller.dart';
import '../controllers/settings_controller.dart';
import '../services/sound_service.dart';

class PetOverlay extends StatelessWidget {
  const PetOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final petCtrl = Get.find<PetController>();
    final screenSize = MediaQuery.of(context).size;
    final settingsCtrl = Get.find<SettingsController>();

    return Obx(() {
      final pet = petCtrl.equippedPet;
      if (pet == null) return const SizedBox.shrink();

      if (settingsCtrl.hidePetOverlay.value) {
        return const SizedBox.shrink();
      }

      return Positioned(
        left: petCtrl.posX.value,
        top: petCtrl.posY.value,
        child: Draggable(
          feedback: Image.asset(
            'assets/gifs/${pet.gif}',
            width: 80,
          ),
          childWhenDragging: const SizedBox.shrink(),
          onDragEnd: (details) {
            petCtrl.updatePosition(details.offset, screenSize);
          },
          child: GestureDetector(
            onTap: () {
              SoundService.playSfx('sounds/${pet.sound}'); 
            },
            child: Image.asset(
              'assets/gifs/${pet.gif}',
              width: 80,
            ),
          ),
        ),
      );
    });
  }
}
