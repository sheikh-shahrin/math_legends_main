import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_legends/services/sound_service.dart';
import 'package:math_legends/controllers/popup_controller.dart';

class PopupConfig {
  static void showOkPopup(String title, String msg) {
    if (Get.isDialogOpen == true) {
      Get.back(closeOverlays: true);
    }

    final PopupController controller = Get.put(PopupController());

    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1A2B),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFF4FC3F7),
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x802196F3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFE3F2FD),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  msg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Ubuntu',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFBBDEFB),
                  ),
                ),
                const SizedBox(height: 22),
                GestureDetector(
                  onTapDown: (_) => controller.pressDown(),
                  onTapUp: (_) => controller.release(),
                  onTapCancel: controller.release,
                  onTap: () {
                    SoundService.playSfx('sounds/button_click.mp3');
                    Get.back();
                    Get.delete<PopupController>();
                  },
                  child: Obx(
                    () => AnimatedScale(
                      scale: controller.isPressed.value ? 0.92 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF64B5F6),
                              Color(0xFF1E88E5),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x802196F3),
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            fontFamily: 'Ubuntu',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
