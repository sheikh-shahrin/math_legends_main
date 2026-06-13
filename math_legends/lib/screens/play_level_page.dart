import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_legends/configs/generic_layout.dart';
import 'package:math_legends/configs/buttons.dart';
import 'package:math_legends/configs/text_stroke.dart';
import 'package:math_legends/controllers/game_controller.dart';
import 'package:math_legends/utils/game_data.dart';
import 'package:math_legends/utils/player_progress.dart';

class PlayLevelPage extends StatelessWidget {
  const PlayLevelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Get.find<GameController>();
    final chapter = game.currentChapter.value!;

    return GenericLayout(
      title: 'Lv ${game.level.value}',
      solidColor: const Color(0xFF2E1A8A),
      gradientColor: const [Color(0xFF6A11CB), Color(0xFF2575FC)],
      strokeColor: const Color(0xFF0F1220),
      children: [
        const SizedBox(height: 14),
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.72,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(22),
              border:
                  Border.all(color: Colors.white.withOpacity(0.75), width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _topHud(game),

                  const SizedBox(height: 20),

                  /// QUESTION / INSTRUCTION
                  Obx(() => _instruction(game)),

                  const SizedBox(height: 20),

                  /// GAMEPLAY UI
                  Obx(() {
                    if (game.endReason.value != LevelEndReason.none) {
                      return const SizedBox.shrink();
                    }

                    switch (chapter.id) {
                      case 5:
                        return _orderUI(game);
                      case 6:
                        return _formationUI(game);
                      case 7:
                        return _fractionUI(game);
                      default:
                        return _arithmeticUI(game);
                    }
                  }),

                  const SizedBox(height: 20),

                  /// FEEDBACK (Correct / Wrong)
                  Obx(() {
                    if (!game.showResult.value ||
                        game.endReason.value != LevelEndReason.none) {
                      return const SizedBox.shrink();
                    }

                    return StrokeText(
                      game.wasCorrect.value ? 'Correct!' : 'Wrong!',
                      fontSize: 22,
                      fillColor: game.wasCorrect.value
                          ? Colors.greenAccent[700]!
                          : Colors.redAccent,
                      strokeColor: Colors.black,
                      strokeWidth: 5,
                    );
                  }),

                  /// ============================
                  /// 🟢 END OF LEVEL / TIME UP UI
                  /// ============================
                  Obx(() {
                    if (game.endReason.value == LevelEndReason.none) {
                      return const SizedBox.shrink();
                    }

                    final rankData = PlayerProgress.getRank(game.user.rp ?? 0);
                    final level = PlayerProgress.getLevel(game.user.xp ?? 0);

                    return Column(
                      children: [
                        const SizedBox(height: 24),
                        StrokeText(
                          game.endReason.value == LevelEndReason.timeUp
                              ? "TIME'S UP!"
                              : (game.correctCount.value ==
                                      GameData.roundsPerLevel
                                  ? "LEVEL COMPLETE!"
                                  : "LEVEL FAILED"),
                          fontSize: 28,
                          fillColor:
                              game.correctCount.value == GameData.roundsPerLevel
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                          strokeColor: Colors.black,
                          strokeWidth: 5,
                        ),
                        const SizedBox(height: 16),
                        _statRow(
                          "Correct",
                          "${game.correctCount.value}/${GameData.roundsPerLevel}",
                        ),
                        _statRow(
                          "Coins Earned",
                          "+${game.earnedCoins.value}",
                        ),
                        _statRow(
                          "XP Earned",
                          "+${game.earnedXp.value.toStringAsFixed(0)}",
                        ),
                        _statRow(
                          "RP Earned",
                          "${game.earnedRp.value >= 0 ? '+' : ''}${game.earnedRp.value.toStringAsFixed(0)}",
                        ),
                        game.petMultiplier > 1
                            ? _statRow(
                                "Pet Bonus",
                                "x${game.petMultiplier.toStringAsFixed(2)}",
                              )
                            : const SizedBox(),
                        _statRow("Level", "$level"),
                        _statRow(
                          "Rank",
                          "${rankData['rank']} ${rankData['tier']}",
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          btnWidth: 200,
                          text: "Continue",
                          gradientColors: const [
                            Colors.orange,
                            Colors.deepOrange
                          ],
                          borderColor: Colors.orangeAccent,
                          textStrokeColor: Colors.black,
                          onPressed: () => Get.back(result: true),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 16),

                  StrokeText(
                    'Chapter ${chapter.id}: ${chapter.name} (x${chapter.multiplier.toStringAsFixed(0)})',
                    fontSize: 14,
                    fillColor: Colors.white70,
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

  // =========================
  // HUD
  // =========================
  Widget _topHud(GameController game) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => StrokeText(
                  'Round ${game.round.value}/${GameData.roundsPerLevel}',
                  fontSize: 16,
                  fillColor: Colors.white,
                  strokeColor: Colors.black,
                  strokeWidth: 3,
                )),
            Obx(() => StrokeText(
                  _fmt(game.secondsLeft.value),
                  fontSize: 16,
                  fillColor: Colors.yellowAccent,
                  strokeColor: Colors.black,
                  strokeWidth: 3,
                )),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => StrokeText(
              '🪙 ${game.totalCoins.value}',
              fontSize: 16,
              fillColor: Colors.amberAccent,
              strokeColor: Colors.black,
              strokeWidth: 3,
            )),
        const SizedBox(height: 8),
        // Buy Potion Button
        CustomButton(
          onPressed: () => game.buyExtraTime(),
          text: '+15 Seconds\n(100 Coins)',

          // Timer theme colors (Required by your constructor)
          gradientColors: [Colors.cyan.shade400, Colors.blue.shade700],
          borderColor: Colors.white,
          textStrokeColor: Colors.black,

          // Overriding your defaults to make it small enough for the top HUD
          fontSize: 14,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ],
    );
  }

  // =========================
  // INSTRUCTION
  // =========================

  Widget _instruction(GameController game) {
    final q = game.currentQuestion.value;
    if (q == null) return const SizedBox.shrink();

    // Use a switch expression for cleaner assignment
    final String text = switch (q) {
      GameQuestion g => g.display,
      _ => q.instruction,
    };

    return StrokeText(
      text,
      fontSize: q is GameQuestion ? 26 : 22,
      fillColor: Colors.white,
      strokeColor: Colors.black,
      strokeWidth: 4,
      textAlign: TextAlign.center,
    );
  }

  // =========================
  // PLACEHOLDERS (already in your file)
  // =========================
  Widget _arithmeticUI(GameController game) {
    return Column(
      children: [
        /// DROP TARGET
        DragTarget<int>(
          onAccept: (v) => game.submitAnswer(v),
          builder: (_, __, ___) => const SquareTextContainer(
            text: '?',
            size: 96,
            backgroundColor: Colors.blueGrey,
            borderColor: Colors.white,
            borderWidth: 4,
            textStyle: TextStyle(
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        const SizedBox(height: 20),

        /// ANSWER CHOICES
        Obx(() {
          if (game.choices.isEmpty) return const SizedBox.shrink();

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: game.choices.map((v) {
              return Draggable<int>(
                data: v,
                feedback: _answerBox(v, dragging: true),
                childWhenDragging: Opacity(opacity: 0.35, child: _answerBox(v)),
                child: _answerBox(v),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _answerBox(int v, {bool dragging = false}) {
    return SquareTextContainer(
      text: '$v',
      size: 70,
      backgroundColor: dragging ? Colors.orangeAccent : const Color(0xFF2F6BFF),
      borderColor: const Color(0xFF66B2FF),
      borderWidth: 4,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _orderUI(GameController game) {
    return Column(
      children: [
        /// ORDER SLOTS
        Obx(() {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(game.orderSlots.length, (i) {
                final value = game.orderSlots[i];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: DragTarget<double>(
                    onWillAccept: (_) => value == null,
                    onAccept: (v) => game.placeOrderNumber(i, v),
                    builder: (_, candidate, __) {
                      return GestureDetector(
                        onTap: () => game.removeOrderNumber(i),
                        child: SquareTextContainer(
                          text: value == null
                              ? (candidate.isNotEmpty ? 'DROP' : '?')
                              : _fmtNum(value),
                          size: 70,
                          backgroundColor: value != null
                              ? const Color(0xFF185A9D)
                              : Colors.blueGrey,
                          borderColor: Colors.white,
                          borderWidth: 4,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          );
        }),

        const SizedBox(height: 20),

        /// NUMBER POOL
        Obx(() {
          if (game.choices.isEmpty) {
            return const StrokeText(
              'All placed! Tap a box to undo.',
              fontSize: 14,
              fillColor: Colors.white70,
              strokeColor: Colors.black,
              strokeWidth: 3,
            );
          }

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: game.choices.cast<double>().map((v) {
              return Draggable<double>(
                data: v,
                feedback: _orderChip(_fmtNum(v), dragging: true),
                childWhenDragging:
                    Opacity(opacity: 0.35, child: _orderChip(_fmtNum(v))),
                child: _orderChip(_fmtNum(v)),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

// =========================
// CHAPTER 6 (Formation) — FIXED
// =========================
  Widget _formationUI(GameController game) {
    final q = game.currentQuestion.value as FormationQuestion;
    final slotCount = q.digits.length;

    return Column(
      children: [
        /// DIGIT SLOTS — ONE SCROLLABLE ROW
        Obx(() {
          return SizedBox(
            height: 80, // hard height prevents layout jump
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(slotCount, (i) {
                  final value = game.formationSlots[i];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: DragTarget<int>(
                      onWillAccept: (v) => value == null,
                      onAccept: (v) => game.placeFormationDigit(i, v),
                      builder: (context, candidate, rejected) {
                        final hovering = candidate.isNotEmpty;

                        return GestureDetector(
                          onTap: () => game.removeFormationDigit(i),
                          child: SquareTextContainer(
                            text:
                                value?.toString() ?? (hovering ? 'DROP' : '_'),
                            size: 64,
                            backgroundColor: value != null
                                ? const Color(0xFF185A9D)
                                : hovering
                                    ? Colors.green.withOpacity(0.65)
                                    : Colors.blueGrey,
                            borderColor: value != null
                                ? const Color(0xFF2EE6A6)
                                : Colors.white,
                            borderWidth: 4,
                            textStyle: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
          );
        }),

        const SizedBox(height: 22),

        /// DIGIT POOL (this already works — untouched)
        Obx(() {
          if (game.formationPool.isEmpty) {
            return const StrokeText(
              'All digits placed. Tap a slot to undo.',
              fontSize: 14,
              fillColor: Colors.white70,
              strokeColor: Colors.black,
              strokeWidth: 3,
              textAlign: TextAlign.center,
            );
          }

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: game.formationPool.map((v) {
              return Draggable<int>(
                data: v,
                feedback: _digitChip(v, dragging: true),
                childWhenDragging: Opacity(
                  opacity: 0.35,
                  child: _digitChip(v),
                ),
                child: _digitChip(v),
              );
            }).toList(),
          );
        }),

        const SizedBox(height: 10),

        const StrokeText(
          'Tap a filled box to remove a digit',
          fontSize: 12,
          fillColor: Colors.white70,
          strokeColor: Colors.black,
          strokeWidth: 3,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

// =========================
// ORDER HELPERS (Chapter 5)
// =========================

  Widget _orderChip(String text, {bool dragging = false}) {
    return SquareTextContainer(
      text: text,
      size: 70,
      backgroundColor: dragging ? Colors.orangeAccent : const Color(0xFF2F6BFF),
      borderColor: const Color(0xFF66B2FF),
      borderWidth: 4,
      textStyle: const TextStyle(
        fontSize: 18,
        color: Colors.white,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  /// Nice formatting:
  /// 12.0 -> 12
  /// 12.50 -> 12.5
  /// 12.33 -> 12.33
  String _fmtNum(double n) {
    if (n % 1 == 0) return n.toInt().toString();

    // Trim trailing zeros nicely (e.g. 12.50 -> 12.5, 12.00 -> 12)
    final s = n.toStringAsFixed(2);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  Widget _digitChip(int v, {bool dragging = false}) {
    return SquareTextContainer(
      text: '$v',
      size: 60,
      backgroundColor: dragging ? Colors.orangeAccent : const Color(0xFF2F6BFF),
      borderColor: const Color(0xFF66B2FF),
      borderWidth: 4,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StrokeText(
            label,
            fontSize: 16,
            fillColor: Colors.white,
            strokeColor: Colors.black,
            strokeWidth: 3,
          ),
          StrokeText(
            value,
            fontSize: 16,
            fillColor: Colors.yellowAccent,
            strokeColor: Colors.black,
            strokeWidth: 3,
          ),
        ],
      ),
    );
  }

  static String _fmt(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _fractionUI(GameController game) {
    return Column(
      children: [
        // The Vertical Fraction Display
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Numerator Slot
              _fractionDropSlot(game, true),

              // Fraction Bar (The horizontal line)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 80, // Slightly wider than the boxes
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Denominator Slot
              _fractionDropSlot(game, false),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Answer Pool (Draggable Choices)
        Obx(() {
          if (game.choices.isEmpty) return const SizedBox.shrink();

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: game.choices.cast<int>().map((v) {
              return Draggable<int>(
                data: v,
                feedback: _answerBox(v, dragging: true),
                childWhenDragging: Opacity(opacity: 0.35, child: _answerBox(v)),
                child: _answerBox(v),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _fractionDropSlot(GameController game, bool isNumerator) {
    return Obx(() {
      final val = isNumerator
          ? game.fractionNumInput.value
          : game.fractionDenInput.value;

      return DragTarget<int>(
        onAccept: (v) => game.submitFraction(v, isNumerator),
        builder: (context, candidate, rejected) {
          final hovering = candidate.isNotEmpty;

          return GestureDetector(
            // NEW: Tap to remove
            onTap: () => game.removeFractionDigit(isNumerator),
            child: SquareTextContainer(
              text: val?.toString() ?? (hovering ? 'DROP' : '?'),
              size: 70,
              backgroundColor: val != null
                  ? const Color(0xFF185A9D)
                  : hovering
                      ? Colors.green.withOpacity(0.6)
                      : Colors.blueGrey,
              borderColor: val != null ? Colors.greenAccent : Colors.white,
              borderWidth: 4,
              textStyle: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      );
    });
  }
}
