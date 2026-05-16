import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_legends/configs/generic_layout.dart';
import 'package:math_legends/configs/buttons.dart';
import 'package:math_legends/configs/text_stroke.dart';
import 'package:math_legends/utils/game_data.dart';
import 'package:math_legends/controllers/game_controller.dart';
import 'package:math_legends/controllers/user_controller.dart';

import '../models/user_model.dart';
import '../services/sound_service.dart';
import 'play_level_page.dart';

class LevelsPage extends StatelessWidget {
  final GameChapter chapter;
  const LevelsPage({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return GenericLayout(
      title: 'Chapter ${chapter.id}',
      solidColor: const Color(0xFF2E1A8A),
      gradientColor: const [Color(0xFF6A11CB), Color(0xFF2575FC)],
      strokeColor: const Color(0xFF0F1220),
      children: [
        const SizedBox(height: 18),

        /// CHAPTER NAME
        Center(
          child: StrokeText(
            chapter.name,
            fontSize: 22,
            fillColor: Colors.white,
            strokeColor: Colors.black,
            strokeWidth: 4,
          ),
        ),

        const SizedBox(height: 12),

        /// MULTIPLIER
        Center(
          child: StrokeText(
            'Stage Multiplier: x${chapter.multiplier.toStringAsFixed(0)}',
            fontSize: 16,
            fillColor: Colors.yellowAccent,
            strokeColor: Colors.black,
            strokeWidth: 3,
          ),
        ),

        const SizedBox(height: 18),

        /// LEVEL GRID (SCROLLABLE)
        Expanded(
          child: Obx(() {
            final user = Get.find<UserController>().user.value!;
            final stats = user.playStats ?? PlayStats(1, 1);

            bool isLocked(int lvl) {
              if (chapter.id < stats.chapter!) return false;
              if (chapter.id > stats.chapter!) return true;
              return lvl > stats.stage!;
            }

            Color stageColor(int lvl) {
              if (chapter.id < stats.chapter!) return Colors.green;
              if (chapter.id == stats.chapter!) {
                if (lvl < stats.stage!) return Colors.green;
                if (lvl == stats.stage!) return Colors.blue;
                return const Color(0xFF1E1E1E);
              }
              return const Color(0xFF1E1E1E);
            }

            Color stageBorderColor(int lvl) {
              if (chapter.id < stats.chapter!) return Colors.green[300]!;
              if (chapter.id == stats.chapter!) {
                if (lvl < stats.stage!) return Colors.green[300]!;
                if (lvl == stats.stage!) return Colors.blue[300]!;
                return const Color(0xFF6A5B2E);
              }
              return const Color(0xFF6A5B2E);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: GameData.levelsPerChapter,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, i) {
                  final lvl = i + 1;
                  final locked = isLocked(lvl);

                  return CustomButton(
                    btnWidth: double.infinity,
                    onPressed: () async {
                      if (locked) {
                        if (Get.isSnackbarOpen) return;

                        SoundService.playSfx('sounds/error_sound.mp3');

                        Get.rawSnackbar(
                          borderRadius: 30,
                          maxWidth: MediaQuery.of(context).size.width * .85,
                          margin: const EdgeInsets.only(top: 15),
                          messageText: const Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '🔒 Complete earlier stages to unlock this',
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
                      final gameCtrl = Get.put(GameController());

                      gameCtrl.startLevel(
                        userModel: user,
                        chapter: chapter,
                        levelNumber: lvl,
                      );

                      final result = await Get.to(() => const PlayLevelPage());

                      if (result == true) {
                        await userCtrl.reloadUser();
                      }
                    },
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    gradientColors: [stageColor(lvl), stageColor(lvl)],
                    borderColor: stageBorderColor(lvl),
                    text: !locked ? '$lvl' : '🔒',
                    textStrokeColor: Colors.black,
                    fontSize: 30,
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
