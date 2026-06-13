import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_legends/controllers/pet_controller.dart';
import 'package:math_legends/models/user_model.dart';
import 'package:math_legends/services/firestore_user_service.dart';
import 'package:math_legends/utils/game_data.dart';

import '../services/sound_service.dart';

class GameQuestion {
  final int a;
  final int b;
  final String op; // + - × ÷
  final int answer;

  const GameQuestion({
    required this.a,
    required this.b,
    required this.op,
    required this.answer,
  });

  String get display => '$a $op $b = ?';
}

class OrderQuestion {
  final List<double> numbers;
  final bool ascending;

  OrderQuestion({
    required this.numbers,
    required this.ascending,
  });

  String get instruction =>
      ascending ? 'Arrange Smallest → Largest' : 'Arrange Largest → Smallest';
}

class FormationQuestion {
  final List<int> digits;
  final bool even;
  final bool multiple;
  final int x;

  FormationQuestion({
    required this.digits,
    required this.even,
    required this.multiple,
    required this.x,
  });

  String get instruction {
    final eo = even ? 'EVEN' : 'ODD';
    if (x == 0) {
      return 'Form the LARGEST $eo number';
    }
    return 'Form the LARGEST $eo number\n'
        '${multiple ? 'Multiple' : 'Factor'} of $x';
  }
}

class FractionQuestion {
  final int num1, den1, num2, den2;
  final String op; // + or -
  final int ansNum, ansDen;

  FractionQuestion({
    required this.num1,
    required this.den1,
    required this.num2,
    required this.den2,
    required this.op,
    required this.ansNum,
    required this.ansDen,
  });

  String get instruction => 'Solve: $num1/$den1 $op $num2/$den2';

  // Helper to find GCD for simplification
  static int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);
}

class OrderOfOpsQuestion {
  final String expression;
  final int answer;

  OrderOfOpsQuestion({required this.expression, required this.answer});

  String get instruction => 'Solve: $expression';
}

enum LevelEndReason {
  none,
  completed,
  timeUp,
}

class GameController extends GetxController {
  final _rng = Random();

  final currentChapter = Rxn<GameChapter>();
  final level = 1.obs; // 1..10

  final round = 1.obs; // 1..5
  final secondsLeft = 0.obs;

  final currentQuestion =
      Rxn<dynamic>(); // GameQuestion | OrderQuestion | FormationQuestion
  final choices = <dynamic>[].obs; // int | double | digit
  final droppedAnswers = <dynamic>[].obs; // for drag-drop chapters

  final showResult = false.obs;
  final wasCorrect = false.obs;

  final fractionNumInput = Rxn<int>();
  final fractionDenInput = Rxn<int>();

  late User user; // passed in at start

  Timer? _timer;

  final _firestore = FirestoreUserService();
  final orderSlots = <double?>[].obs; // slots for chapter 5

  final formationSlots = <int?>[].obs; // nullable slots
  final formationPool = <int>[].obs; // draggable digits pool

  final isTimeUp = false.obs;
  final levelEnded = false.obs;

  final earnedXp = 0.0.obs;
  final earnedRp = 0.0.obs;

  final isLevelEnded = false.obs;
  final endReason = LevelEndReason.none.obs;

  final correctCount = 0.obs;

  final earnedCoins = 0.obs;

  // --- POTION VARIABLES ---
  final totalCoins = 0.obs; // Tracks total coins reactively during the game
  final int timeCost = 100;
  final int timeReward = 15;
  // ------------------------

  // --------------------------
  // START / STOP
  // --------------------------
  void startLevel({
    required User userModel,
    required GameChapter chapter,
    required int levelNumber,
  }) {
    user = userModel;
    totalCoins.value = user.coins ?? 0; 
    currentChapter.value = chapter;
    level.value = levelNumber;

    round.value = 1;
    secondsLeft.value = GameData.timeLimitSeconds(levelNumber);

    earnedXp.value = 0;
    earnedRp.value = 0;
    correctCount.value = 0;
    earnedCoins.value = 0;
    endReason.value = LevelEndReason.none;

    _startTimer();
    _newRound();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsLeft.value <= 0) {
        _onTimeUp();
        return;
      }
      secondsLeft.value--;
    });
  }

  void _onTimeUp() {
    if (endReason.value != LevelEndReason.none) return;

    _timer?.cancel();
    endReason.value = LevelEndReason.timeUp;

    _applyEnd(); // DO NOT submitAnswer()
  }

  // --------------------------
  // POTIONS / POWER-UPS
  // --------------------------
  Future<void> buyExtraTime() async {
    // 1. Prevent buying if the level is already over
    if (endReason.value != LevelEndReason.none) return;

    // 2. Check if the player has enough coins
    if (totalCoins.value >= timeCost) {
      
      // Deduct coins locally
      totalCoins.value -= timeCost;
      user.coins = totalCoins.value;

      // Add time
      secondsLeft.value += timeReward;

      // Play success/purchase sound
      SoundService.playSfx('sounds/purchase.mp3');

      // Save to Firestore IMMEDIATELY. 
      // (This prevents a cheat where players buy time, win, but force-close the app to keep their coins).
      await _firestore.updateUserCoins(uid: user.uid!, coins: totalCoins.value);

      // Show success message
      Get.snackbar(
        'Time Added!',
        '+$timeReward seconds. Keep going!',
        backgroundColor: Colors.greenAccent[700]?.withOpacity(0.9),
        colorText: Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );
      
    } else {
      
      // Play error sound
      SoundService.playSfx('sounds/error_sound.mp3');
      
      // Show error message
      Get.snackbar(
        'Not Enough Coins',
        'You need $timeCost coins to buy more time.',
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      );
    }
  }

  // --------------------------
  // GAME LOOP
  // --------------------------
  void _newRound() {
    showResult.value = false;
    wasCorrect.value = false;
    droppedAnswers.clear();

    final ch = currentChapter.value!;

    switch (ch.id) {
      case 5:
        final q = _generateOrderQuestion(level.value);
        currentQuestion.value = q;
        final list = q.numbers.toList()..shuffle(_rng);
        choices.value = list; // pool
        orderSlots.value = List<double?>.filled(q.numbers.length, null);
        break;

      case 6:
        {
          final q = _generateFormationQuestion(level.value);
          currentQuestion.value = q;

          _startFormationRound(q);
          break;
        }
      case 7:
        fractionNumInput.value = null;
        fractionDenInput.value = null;

        final q = _generateFractionQuestion(level.value);
        currentQuestion.value = q;
        choices.value = _generateFractionChoices(q);
        break;
      case 8:
        final q = _generateOrderOfOpsQuestion(level.value);
        currentQuestion.value = q;
        // Reuses the standard choice generator for the single answer
        choices.value = _generateChoices(correct: q.answer);
        break;

      default:
        final q = _generateQuestion(
          chapterId: ch.id,
          levelNumber: level.value,
        );
        currentQuestion.value = q;
        choices.value = _generateChoices(correct: q.answer);
    }
  }

  List<int> _generateFractionChoices(FractionQuestion q) {
    // Use a set to ensure unique numbers in the pool
    final set = <int>{q.ansNum, q.ansDen};

    // Add common small numbers and numbers from the question to the pool
    set.addAll([q.num1, q.den1, q.num2, q.den2]);

    while (set.length < 8) {
      int candidate = _rng.nextInt(15) + 1;
      set.add(candidate);
    }

    return set.toList()..shuffle(_rng);
  }

  FractionQuestion _generateFractionQuestion(int level) {
    int n1, d1, n2, d2, finalNum, finalDen;
    String op = _rng.nextBool() ? '+' : '-';

    while (true) {
      if (level <= 5) {
        // Level 1-5: Same denominators
        d1 = d2 = _rng.nextInt(7) + 3; // Denominator 3-9
        n1 = _rng.nextInt(d1 - 1) + 1;
        n2 = _rng.nextInt(d1 - 1) + 1;
      } else {
        // Level 6-10: Different denominators
        d1 = _rng.nextInt(5) + 2; // 2-6
        d2 = _rng.nextInt(5) + 2; // 2-6
        n1 = _rng.nextInt(d1 - 1) + 1;
        n2 = _rng.nextInt(d2 - 1) + 1;
      }

      // Calculate cross-multiplied result: (n1/d1) +/- (n2/d2)
      if (op == '+') {
        finalNum = (n1 * d2) + (n2 * d1);
      } else {
        finalNum = (n1 * d2) - (n2 * d1);
      }
      finalDen = d1 * d2;

      // Requirement: Result must be > 0 and < 1
      if (finalNum > 0 && finalNum < finalDen) {
        // Simplify the answer (e.g., 6/8 -> 3/4)
        int common = FractionQuestion.gcd(finalNum, finalDen);
        return FractionQuestion(
          num1: n1,
          den1: d1,
          num2: n2,
          den2: d2,
          op: op,
          ansNum: finalNum ~/ common,
          ansDen: finalDen ~/ common,
        );
      }
      // If conditions aren't met, loop continues to try new numbers
    }
  }

  void removeFractionDigit(bool isNumerator) {
    final val = isNumerator ? fractionNumInput.value : fractionDenInput.value;

    if (val == null) return; // Nothing to remove

    // 1. Clear the slot
    if (isNumerator) {
      fractionNumInput.value = null;
    } else {
      fractionDenInput.value = null;
    }

    // 2. Put the value back into the draggable pool
    choices.add(val);

    // 3. Optional: Shuffle so it doesn't always go to the end
    choices.shuffle(_rng);
  }

  OrderOfOpsQuestion _generateOrderOfOpsQuestion(int level) {
    while (true) {
      int result = 0;
      String expression = "";

      // Level 1-7: 3 terms | Level 8-10: 4 terms
      int termCount = (level >= 8) ? 4 : 3;
      List<int> numbers = List.generate(termCount, (_) => _rng.nextInt(10) + 1);

      // Operations pool: include division only from level 5 onwards
      List<String> ops = ['+', '-', '×'];
      if (level >= 5) ops.add('÷');

      if (termCount == 3) {
        // Structure: (a op1 b) op2 c
        int a = numbers[0];
        int b = numbers[1];
        int c = numbers[2];
        String op1 = ops[_rng.nextInt(ops.length)];
        String op2 = ops[_rng.nextInt(ops.length)];

        // Calculate first part (a op1 b)
        var res1 = _eval(a, b, op1);
        if (res1 == null || res1 < 0) continue;

        // Calculate second part (res1 op2 c)
        var res2 = _eval(res1, c, op2);
        if (res2 == null || res2 <= 0) {
          continue; // Must be positive whole number
        }

        expression =
            "($a ${op1.replaceAll('×', 'x').replaceAll('÷', '/')} $b) $op2 $c";
        result = res2;
      } else {
        // Structure: (a op1 b) op2 (c op3 d)
        String op1 = ops[_rng.nextInt(ops.length)];
        String op2 = ops[_rng.nextInt(ops.length)];
        String op3 = ops[_rng.nextInt(ops.length)];

        var resPart1 = _eval(numbers[0], numbers[1], op1);
        var resPart2 = _eval(numbers[2], numbers[3], op3);

        if (resPart1 == null || resPart1 < 0) continue;
        if (resPart2 == null || resPart2 < 0) continue;

        var finalRes = _eval(resPart1, resPart2, op2);
        if (finalRes == null || finalRes <= 0) continue;

        expression =
            "(${numbers[0]} $op1 ${numbers[1]}) $op2 (${numbers[2]} $op3 ${numbers[3]})";
        result = finalRes;
      }

      return OrderOfOpsQuestion(
        expression: expression.replaceAll('*', '×').replaceAll('/', '÷'),
        answer: result,
      );
    }
  }

// Helper to evaluate and ensure whole numbers for division
  int? _eval(int a, int b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        if (b == 0 || a % b != 0) return null; // Ensure no remainder
        return a ~/ b;
      default:
        return null;
    }
  }

  void submitFraction(int? value, bool isNumerator) {
    if (value == null) return;

    // If the slot already had a value, put the OLD one back in the pool first
    final oldVal =
        isNumerator ? fractionNumInput.value : fractionDenInput.value;
    if (oldVal != null) {
      choices.add(oldVal);
    }

    // Set the new value
    if (isNumerator) {
      fractionNumInput.value = value;
    } else {
      fractionDenInput.value = value;
    }

    // Remove the NEW value from the draggable choices pool
    choices.remove(value);

    // Auto-submit if both are filled
    if (fractionNumInput.value != null && fractionDenInput.value != null) {
      final q = currentQuestion.value as FractionQuestion;
      bool isRight = fractionNumInput.value == q.ansNum &&
          fractionDenInput.value == q.ansDen;
      submitAnswer(null, fractionCorrect: isRight);
    }
  }

  void _startFormationRound(FormationQuestion q) {
    formationSlots.assignAll(List<int?>.filled(q.digits.length, null));
    formationPool.assignAll(q.digits.toList()..shuffle(_rng));
  }

  void placeFormationDigit(int index, int digit) {
    if (formationSlots[index] != null) return;

    formationSlots[index] = digit;
    formationPool.remove(digit);

    // auto-submit when complete
    if (!formationSlots.any((d) => d == null)) {
      submitFormation();
    }
  }

  Future<void> submitFormation() async {
    if (endReason.value != LevelEndReason.none) return;

    final q = currentQuestion.value as FormationQuestion;
    final isRight = checkFormationAnswer(formationSlots, q);

    if (isRight) correctCount.value++;

    final petMult = petMultiplier;
    final chapterMult = currentChapter.value!.multiplier;

    earnedXp.value += 5 * chapterMult * petMult;
    earnedRp.value += isRight ? 5 * chapterMult * petMult : -4 * chapterMult;

    final baseCoins = isRight ? 5 : 0;
    earnedCoins.value += (baseCoins * chapterMult * petMult).round();

    isRight
        ? SoundService.playSfx('sounds/correct_ans.mp3')
        : SoundService.playSfx('sounds/wrong_ans.mp3');

    showResult.value = true;
    wasCorrect.value = isRight;

    await Future.delayed(const Duration(milliseconds: 700));

    if (round.value >= GameData.roundsPerLevel) {
      endReason.value = LevelEndReason.completed;
      _applyEnd();
    } else {
      round.value++;
      _newRound();
    }
  }

  void removeFormationDigit(int index) {
    final v = formationSlots[index];
    if (v == null) return;

    formationSlots[index] = null;
    formationSlots.refresh();

    formationPool.add(v);
    formationPool.shuffle(_rng);
  }

  void placeOrderNumber(int slotIndex, double value) {
    if (slotIndex < 0 || slotIndex >= orderSlots.length) return;
    if (orderSlots[slotIndex] != null) return; // slot filled

    // prevent duplicates
    if (orderSlots.contains(value)) return;

    orderSlots[slotIndex] = value;
    orderSlots.refresh();

    // remove from pool
    choices.remove(value);

    // auto-submit if complete
    if (orderSlots.every((e) => e != null)) {
      submitAnswer(1); // trigger
    }
  }

  void removeOrderNumber(int slotIndex) {
    if (slotIndex < 0 || slotIndex >= orderSlots.length) return;
    final v = orderSlots[slotIndex];
    if (v == null) return;

    orderSlots[slotIndex] = null;
    orderSlots.refresh();

    // add back to pool
    choices.add(v);
    choices.shuffle(_rng);
  }

  Future<void> submitAnswer(int? picked, {bool? fractionCorrect}) async {
    if (endReason.value != LevelEndReason.none) return;

    bool isRight = false;
    final ch = currentChapter.value!;
    final mult = ch.multiplier;

    // --- VALIDATION LOGIC ---
    if (fractionCorrect != null) {
      // Used by Chapter 7 (Fractions)
      isRight = fractionCorrect;
    } else if (ch.id <= 4) {
      // Basic Arithmetic
      isRight = picked == (currentQuestion.value as GameQuestion).answer;
    } else if (ch.id == 5) {
      // Order
      isRight =
          checkOrderAnswer(orderSlots.cast<double>(), currentQuestion.value);
    } else if (ch.id == 6) {
      // Formation
      isRight = checkFormationAnswer(formationSlots, currentQuestion.value);
    } else if (ch.id == 8) {
      // Order of Operations (Uses standard GameQuestion/GameController logic)
      isRight = picked == (currentQuestion.value as OrderOfOpsQuestion).answer;
    }
    // -------------------------

    final petMult = petMultiplier;

    earnedXp.value += isRight ? 5 * mult * petMult : 0;
    earnedRp.value += isRight ? 5 * mult * petMult : -4 * mult;

    final baseCoins = isRight ? 5 : 0;
    earnedCoins.value += (baseCoins * mult * petMult).round();

    if (isRight) correctCount.value++;

    isRight
        ? SoundService.playSfx('sounds/correct_ans.mp3')
        : SoundService.playSfx('sounds/wrong_ans.mp3');

    showResult.value = true;
    wasCorrect.value = isRight;

    await Future.delayed(const Duration(milliseconds: 700));

    if (round.value >= GameData.roundsPerLevel) {
      endReason.value = LevelEndReason.completed;
      _applyEnd();
    } else {
      round.value++;
      _newRound();
    }
  }

  Future<void> _applyEnd() async {
    _timer?.cancel();

    final petCtrl = Get.find<PetController>();

    final newXp = (user.xp ?? 0) + earnedXp.value;
    final double newRp = max(0, (user.rp ?? 0) + earnedRp.value);

    final newCoins = (user.coins ?? 0) + earnedCoins.value;
    user.coins = newCoins;

    user.xp = newXp;
    user.rp = newRp;

    await _firestore.updateUserXP(uid: user.uid!, xp: newXp);
    await _firestore.updateUserRP(uid: user.uid!, rp: newRp);
    await _firestore.updateUserCoins(uid: user.uid!, coins: newCoins);

    await petCtrl.updateUserStats(user.uid!);

    if (correctCount.value == GameData.roundsPerLevel) {
      SoundService.playSfx('sounds/win_game.mp3');
      await advancePlayerProgress();
    } else {
      SoundService.playSfx('sounds/lose_game.mp3');
    }
  }

  // --------------------------
  // DIFFICULTY / GENERATION
  // --------------------------
  GameQuestion _generateQuestion({
    required int chapterId,
    required int levelNumber,
  }) {
    // "Harder and harder":
    // Increase number range by chapter + level
    // (tweak these anytime)
    final base = 10 + (chapterId * 6);
    final growth = levelNumber * 4;
    final max = base + growth; // increases with chapter and level

    int a = _rng.nextInt(max - 3) + 3;
    int b = _rng.nextInt(max - 3) + 3;

    switch (chapterId) {
      case 1: // Addition
        return GameQuestion(a: a, b: b, op: '+', answer: a + b);

      case 2: // Subtraction (avoid negative early)
        if (b > a) {
          final t = a;
          a = b;
          b = t;
        }
        return GameQuestion(a: a, b: b, op: '-', answer: a - b);

      case 3: // Multiplication (control size)
        final mMax = 6 + (levelNumber ~/ 2) + chapterId; // grows slowly
        a = _rng.nextInt(mMax - 2) + 2;
        b = _rng.nextInt(mMax - 2) + 2;
        return GameQuestion(a: a, b: b, op: '×', answer: a * b);

      case 4: // Division (ensure integer answer)
        // Make (a ÷ b) integer:
        final dMax = 8 + (levelNumber ~/ 2);
        b = _rng.nextInt(dMax - 1) + 2; // divisor 2..dMax
        final q = _rng.nextInt(dMax - 1) + 2; // quotient 2..dMax
        a = b * q; // divisible
        return GameQuestion(a: a, b: b, op: '÷', answer: a ~/ b);

      default:
        return const GameQuestion(a: 1, b: 1, op: '+', answer: 2);
    }
  }

  OrderQuestion _generateOrderQuestion(int level) {
    int count;
    int max;
    int decimals;

    if (level <= 2) {
      count = 3;
      max = 20;
      decimals = 0;
    } else if (level <= 4) {
      count = 4;
      max = 50;
      decimals = 0;
    } else if (level <= 6) {
      count = 5;
      max = 100;
      decimals = 0;
    } else if (level <= 8) {
      count = 5;
      max = 100;
      decimals = 1;
    } else if (level == 9) {
      count = 6;
      max = 200;
      decimals = 2;
    } else {
      count = 7;
      max = 500;
      decimals = 2;
    }

    final set = <double>{};

    while (set.length < count) {
      double n = _rng.nextInt(max).toDouble();
      if (decimals > 0) {
        n += _rng.nextDouble();
        n = double.parse(n.toStringAsFixed(decimals));
      }
      set.add(n);
    }

    return OrderQuestion(
      numbers: set.toList(),
      ascending: level % 2 == 1,
    );
  }

  bool checkOrderAnswer(List<double> userOrder, OrderQuestion q) {
    final sorted = [...q.numbers]
      ..sort(q.ascending ? (a, b) => a.compareTo(b) : (a, b) => b.compareTo(a));

    for (int i = 0; i < sorted.length; i++) {
      if (userOrder[i] != sorted[i]) return false;
    }
    return true;
  }

  FormationQuestion _generateFormationQuestion(int level) {
    int digitCount;
    int x = 0;
    bool multiple = false;

    if (level <= 5) {
      digitCount = _rng.nextBool() ? 3 : 4;
    } else if (level <= 9) {
      digitCount = _rng.nextBool() ? 5 : 6;
      x = _rng.nextInt(8) + 2; // 2–9
      multiple = _rng.nextBool();
    } else {
      digitCount = 7;
      x = _rng.nextInt(8) + 2;
      multiple = _rng.nextBool();
    }

    final isEvenRequired = _rng.nextBool();
    final digits = List.generate(digitCount, (_) => _rng.nextInt(10));

    // --- LOGIC FIX START ---
    // Check if we have at least one digit that satisfies the even/odd requirement
    bool hasRequiredParity =
        digits.any((d) => isEvenRequired ? d % 2 == 0 : d % 2 != 0);

    if (!hasRequiredParity) {
      // Force one digit to be what we need
      int randomIndex = _rng.nextInt(digitCount);
      if (isEvenRequired) {
        // Replace with a random even digit: 0, 2, 4, 6, or 8
        digits[randomIndex] = _rng.nextInt(5) * 2;
      } else {
        // Replace with a random odd digit: 1, 3, 5, 7, or 9
        digits[randomIndex] = (_rng.nextInt(5) * 2) + 1;
      }
    }
    // --- LOGIC FIX END ---

    return FormationQuestion(
      digits: digits,
      even: isEvenRequired,
      multiple: multiple,
      x: x,
    );
  }

  bool checkFormationAnswer(List<int?> slots, FormationQuestion q) {
    // must be fully filled
    if (slots.any((d) => d == null)) return false;

    final digits = slots.cast<int>();

    // prevent leading zero
    if (digits.isNotEmpty && digits.first == 0) return false;

    final number = int.parse(digits.join());

    // even/odd requirement
    if (q.even && number % 2 != 0) return false;
    if (!q.even && number % 2 == 0) return false;

    // multiple / factor requirement
    if (q.x != 0) {
      if (q.multiple && number % q.x != 0) return false;

      // factor: number must divide x (and can't be 0)
      if (!q.multiple) {
        if (number == 0) return false;
        if (q.x % number != 0) return false;
      }
    }

    return true;
  }

  List<int> _generateChoices({required int correct}) {
    final set = <int>{correct};

    // Use a safety counter to prevent infinite loops if something goes wrong
    int attempts = 0;

    while (set.length < 4 && attempts < 100) {
      attempts++;

      // If the answer is small, we need a larger positive range to avoid collisions
      int range = (correct < 5) ? 10 : 5;

      final delta = _rng.nextInt(range * 2) - range;
      final candidate = correct + delta;

      // Only add if it's positive and not the correct answer
      // (the Set handles the unique check)
      if (candidate >= 0) {
        set.add(candidate);
      }
    }

    // Fallback: If the loop fails to find enough numbers, fill manually
    int fallback = 0;
    while (set.length < 4) {
      if (!set.contains(fallback)) {
        set.add(fallback);
      }
      fallback++;
    }

    final list = set.toList()..shuffle(_rng);
    return list;
  }

  Future<void> advancePlayerProgress() async {
    final stats = user.playStats ?? PlayStats(1, 1);

    int chapter = stats.chapter!;
    int stage = stats.stage!;

    // advance stage
    if (stage < GameData.levelsPerChapter) {
      stage += 1;
    } else {
      // finished last stage → next chapter
      chapter += 1;
      stage = 1;
    }

    // update local user
    user.playStats = PlayStats(chapter, stage);

    // persist to Firestore
    await _firestore.updateUserPlayStats(
      uid: user.uid!,
      chapter: chapter,
      stage: stage,
    );
  }

  double get petMultiplier {
    final petData = user.petData;
    if (petData == null) return 1.0;

    final equipped = petData.petData?.entries
        .firstWhereOrNull((e) => e.value.equipped == true);

    return equipped?.key.multiplier ?? 1.0;
  }
}
