import 'dart:math';

class PlayerProgress {
  /* =========================
     LEVEL SYSTEM (XP)
  ========================= */

  static const double baseXpPerLevel = 100.0;
  static const double levelGrowthRate = 1.15;

  /// Returns current level based on total XP
  static int getLevel(double xp) {
    int level = 1;
    double xpRemaining = xp;

    while (xpRemaining >= xpForLevel(level)) {
      xpRemaining -= xpForLevel(level);
      level++;
    }

    return level;
  }

  /// XP required to advance FROM a given level
  static double xpForLevel(int level) {
    return baseXpPerLevel * pow(levelGrowthRate, level - 1);
  }

  /// Progress (0.0 → 1.0) within current level
  static double getLevelProgress(double xp) {
    int level = getLevel(xp);
    double xpIntoLevel = xp;

    for (int i = 1; i < level; i++) {
      xpIntoLevel -= xpForLevel(i);
    }

    return (xpIntoLevel / xpForLevel(level)).clamp(0.0, 1.0);
  }

  /* =========================
     RANK SYSTEM (RP)
  ========================= */

  static const List<String> ranks = [
    'Novice',
    'Bronze',
    'Silver',
    'Gold',
    'Platinum',
    'Diamond',
    'Legend',
  ];

  static const List<double> rankMultipliers = [
    1.0, // Novice
    1.3, // Bronze
    1.6, // Silver
    2.0, // Gold
    2.5, // Platinum
    3.2, // Diamond
    4.5, // Legend
  ];

  static const int tiersPerRank = 3;
  static const double baseRpPerTier = 500.0;
  static const double tierGrowthRate = 1.25;

  /// Returns rank name + tier based on total RP
  static Map<String, dynamic> getRank(double rp) {
    double rpRemaining = rp;

    for (int rankIndex = 0; rankIndex < ranks.length; rankIndex++) {
      for (int tier = 1; tier <= tiersPerRank; tier++) {
        final requiredRp = rpForTier(rankIndex, tier);

        if (rpRemaining < requiredRp) {
          return {
            'rank': ranks[rankIndex],
            'tier': tier,
          };
        }

        rpRemaining -= requiredRp;
      }
    }

    return {
      'rank': 'Legend',
      'tier': 3,
    };
  }

  /// RP required for a specific rank tier
  static double rpForTier(int rankIndex, int tier) {
    return baseRpPerTier *
        rankMultipliers[rankIndex] *
        pow(tierGrowthRate, tier - 1);
  }

  /// Progress (0.0 → 1.0) within current rank tier
  static double getRankProgress(double rp) {
    double rpRemaining = rp;

    for (int rankIndex = 0; rankIndex < ranks.length; rankIndex++) {
      for (int tier = 1; tier <= tiersPerRank; tier++) {
        final requiredRp = rpForTier(rankIndex, tier);

        if (rpRemaining < requiredRp) {
          return (rpRemaining / requiredRp).clamp(0.0, 1.0);
        }

        rpRemaining -= requiredRp;
      }
    }

    return 1.0;
  }
}
