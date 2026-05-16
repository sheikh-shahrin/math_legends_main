class GameChapter {
  final int id;
  final String name;
  final String? op; // "+", "-", "×", "÷"
  final double multiplier; // stage multiplier

  const GameChapter({
    required this.id,
    required this.name,
    required this.op,
    required this.multiplier,
  });
}

class PetData {
  final int id;
  final String name;
  final double multiplier;
  final String gif;
  final int cost;
  final String sound;

  const PetData(
      {required this.id,
      required this.name,
      required this.multiplier,
      required this.gif,
      required this.cost,
      required this.sound});
}

class GameData {
  static const int levelsPerChapter = 10;
  static const int roundsPerLevel = 5;

  static const pets = <PetData>[
    PetData(
        id: 1,
        name: 'Doggy',
        multiplier: 1.2,
        gif: 'pet_doggy.gif',
        cost: 100,
        sound: 'doggy_sound.mp3'),
    PetData(
        id: 2,
        name: 'Kitty',
        multiplier: 1.5,
        gif: 'pet_kitty.gif',
        cost: 250,
        sound: 'kitty_sound.mp3'),
    PetData(
        id: 3,
        name: 'Bunny',
        multiplier: 2.0,
        gif: 'pet_bunny.gif',
        cost: 1000,
        sound: 'bunny_sound.mp3'),
  ];

  static PetData getPetById(int id) {
    try {
      return pets.firstWhere((p) => p.id == id);
    } catch (_) {
      return pets[0];
    }
  }

  static const chapters = <GameChapter>[
    // Arithmetic chapters
    GameChapter(
      id: 1,
      name: 'Addition',
      op: '+',
      multiplier: 1.0,
    ),
    GameChapter(
      id: 2,
      name: 'Subtraction',
      op: '-',
      multiplier: 2.0,
    ),
    GameChapter(
      id: 3,
      name: 'Multiplication',
      op: '×',
      multiplier: 3.0,
    ),
    GameChapter(
      id: 4,
      name: 'Division',
      op: '÷',
      multiplier: 4.0,
    ),

    // Logic chapters
    GameChapter(
      id: 5,
      name: 'Number Order',
      op: null,
      multiplier: 5.0,
    ),
    GameChapter(
      id: 6,
      name: 'Number Formation',
      op: null,
      multiplier: 6.0,
    ),
    GameChapter(
      id: 7,
      name: 'Fractions I',
      op: null, // Custom UI
      multiplier: 7.0,
    ),
    GameChapter(
      id: 8,
      name: 'Order of Ops',
      op: null, // Custom UI
      multiplier: 8.0,
    ),
  ];

  static int timeLimitSeconds(int level) {
    if (level <= 5) return 90;
    if (level <= 9) return 60;
    return 30;
  }

  /// Helper (OPTIONAL): identify logic-based chapters
  static bool isLogicChapter(int chapterId) {
    return chapterId >= 5;
  }
}
