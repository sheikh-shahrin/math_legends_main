import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_legends/configs/generic_layout.dart';
import 'package:math_legends/configs/buttons.dart';
import 'package:math_legends/configs/text_stroke.dart';
import 'package:math_legends/utils/game_data.dart';

import '../controllers/user_controller.dart';
import '../models/user_model.dart';
import '../services/sound_service.dart';
import 'levels_page.dart';

class ChaptersPage extends StatelessWidget {
  const ChaptersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericLayout(
      title: 'Chapters',
      solidColor: const Color(0xFF2E1A8A),
      gradientColor: const [Color(0xFF6A11CB), Color(0xFF2575FC)],
      strokeColor: const Color(0xFF0F1220),
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  /// CHAPTER BUTTONS
                  Center(
                    child: Obx(() {
                      final user = Get.find<UserController>().user.value!;
                      final stats = user.playStats ?? PlayStats(1, 1);

                      Color chapterColor(int chapterId) {
                        if (chapterId < stats.chapter!) {
                          return Colors.green; // completed
                        }
                        if (chapterId == stats.chapter!) {
                          return Colors.blue; // current
                        }
                        return const Color(0xFF1E1E1E); // locked
                      }

                      Color chapterBorderColor(int chapterId) {
                        if (chapterId < stats.chapter!) {
                          return Colors.green[300]!; // completed
                        }
                        if (chapterId == stats.chapter!) {
                          return Colors.blue[300]!; // current
                        }
                        return const Color(0xFF6A5B2E); // locked
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: GameData.chapters.map((c) {
                          final isLocked = c.id > stats.chapter!;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: CustomButton(
                              btnWidth: MediaQuery.of(context).size.width * .75,
                              btnHeight: 75,
                              onPressed: () async {
                                if (isLocked) {
                                  if (Get.isSnackbarOpen) return;

                                  SoundService.playSfx(
                                      'sounds/error_sound.mp3');

                                  Get.rawSnackbar(
                                    borderRadius: 30,
                                    maxWidth:
                                        MediaQuery.of(context).size.width * .85,
                                    margin: const EdgeInsets.only(top: 15),
                                    messageText: const Center(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '🔒 Complete earlier chapters to unlock this',
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

                                final userCtrl = Get.find<UserController>();
                                final result =
                                    await Get.to(() => LevelsPage(chapter: c));

                                if (result == true) {
                                  await userCtrl.reloadUser();
                                }
                              },
                              gradientColors: [
                                chapterColor(c.id),
                                chapterColor(c.id)
                              ],
                              borderColor: chapterBorderColor(c.id),
                              text: !isLocked
                                  ? 'Chapter ${c.id}: ${c.name}'
                                  : 'LOCKED',
                              textStrokeColor: Colors.black,
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ),

                  const SizedBox(height: 18),

                  /// FOOTER INFO
                  const StrokeText(
                    'Each chapter has 10 levels.\nEach level has 5 rounds.',
                    fontSize: 16,
                    fillColor: Colors.white,
                    strokeColor: Colors.black,
                    strokeWidth: 3,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
