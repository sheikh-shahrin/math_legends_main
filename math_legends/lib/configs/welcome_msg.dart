import 'dart:math';

class CustomWelcomeMessages {
  final String _newPlrMsg = 'Welcome, %s. Begin your journey as a Math Legend.';

  final List<String> _oldPlrMsgList = [
    "Welcome back, %s. Your progress has been saved.",
    "Greetings %s, new math challenges await.",
    "Welcome back, %s. Continue building your legend.",
    "Hello %s, your next challenge is ready.",
    "Welcome back, %s. Skill progression resumes.",
    "Greetings %s, consistency drives mastery.",
    "Welcome back, %s. Your learning path continues.",
    "Hello %s, sharpen your math skills today.",
    "Welcome back, %s. New levels are unlocked.",
    "Greetings %s, accuracy leads to advancement.",
    "Welcome back, %s. Your streak is active.",
    "Hello %s, structured challenges await.",
    "Welcome back, %s. Progress through practice.",
    "Greetings %s, logic and speed matter.",
    "Welcome back, %s. Your achievements are recorded.",
    "Hello %s, continue your daily learning.",
    "Welcome back, %s. Knowledge builds power.",
    "Greetings %s, advance through problem solving.",
    "Welcome back, %s. Mastery is within reach.",
    "Hello %s, your legend grows with effort.",
    "Welcome back, %s. Challenges scale with skill.",
    "Greetings %s, each solution counts.",
    "Welcome back, %s. Learning points await.",
    "Hello %s, focus and proceed.",
    "Welcome back, %s. Your math journey continues.",
    "Greetings %s, discipline drives progress.",
    "Welcome back, %s. New milestones are ready.",
    "Hello %s, reinforce your fundamentals.",
    "Welcome back, %s. Advance through structured play.",
    "Greetings %s, growth comes from consistency.",
    "Welcome back, %s. Skill development is active.",
    "Hello %s, solve and level up.",
    "Welcome back, %s. Your proficiency improves.",
    "Greetings %s, learning never stops.",
    "Welcome back, %s. Accuracy unlocks rewards.",
    "Hello %s, resume your challenges.",
    "Welcome back, %s. Knowledge compounds daily.",
    "Greetings %s, continue your progression.",
    "Welcome back, %s. Your path is set.",
    "Hello %s, build confidence through practice.",
    "Welcome back, %s. Strengthen your math foundation.",
    "Greetings %s, effort defines results.",
    "Welcome back, %s. Your legend continues.",
    "Hello %s, challenges await completion.",
    "Welcome back, %s. Skills are ready to grow.",
    "Greetings %s, return to focused learning.",
    "Welcome back, %s. Progress through persistence.",
    "Hello %s, logic guides your path.",
    "Welcome back, %s. Stay consistent, advance steadily.",
    "Greetings %s, continue becoming a Math Legend."
  ];

  final Random _rand = Random();

  String getMessage({required bool isNewPlayer, required String plrName}) {
    String welcomeMsg = isNewPlayer ? _newPlrMsg : _oldPlrMsgList[_rand.nextInt(_oldPlrMsgList.length)];

    return welcomeMsg.replaceFirst('%s', plrName);
  }
}
