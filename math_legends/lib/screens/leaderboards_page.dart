import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:math_legends/configs/generic_layout.dart';
import 'package:math_legends/configs/text_stroke.dart';
import 'package:math_legends/models/user_model.dart';
import 'package:math_legends/utils/player_progress.dart';

class LeaderboardsPage extends StatefulWidget {
  const LeaderboardsPage({super.key});

  @override
  State<LeaderboardsPage> createState() => _LeaderboardsPageState();
}

class _LeaderboardsPageState extends State<LeaderboardsPage> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();

    // Delay loading to allow Firestore index + auth to settle
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _ready = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final query = FirebaseFirestore.instance
        .collection('users')
        .where('xp', isGreaterThanOrEqualTo: 0)
        .orderBy('xp', descending: true)
        .orderBy('rp', descending: true)
        .limit(50);

    return GenericLayout(
      title: 'Leaderboards',
      solidColor: Colors.brown[300]!,
      gradientColor: const [
        Color(0xFF8D6E63), 
        Color(0xFF5D4037), 
      ],
      strokeColor: const Color(0xFF3E2723),
      children: [
        Expanded(
          child: Container(
            height: size.height,
            width: size.width,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withOpacity(0.75),
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: !_ready
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        StrokeText(
                          'Loading Leaderboards...',
                          fontSize: 16,
                          fillColor: Colors.white,
                          strokeColor: Colors.black,
                          strokeWidth: 3,
                        ),
                      ],
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: query.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        debugPrint('Docs: ${snapshot.data?.docs.length}');
                        debugPrint('Error: ${snapshot.error}');

                        return const Center(
                          child: StrokeText(
                            'Error loading leaderboard',
                            fontSize: 16,
                            fillColor: Colors.redAccent,
                            strokeColor: Colors.black,
                            strokeWidth: 3,
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: StrokeText(
                            'No players yet!',
                            fontSize: 18,
                            fillColor: Colors.white,
                            strokeColor: Colors.black,
                            strokeWidth: 4,
                          ),
                        );
                      }

                      final docs = snapshot.data!.docs;

                      final users = docs.map((d) {
                        final data = d.data() as Map<String, dynamic>?;

                        return User.fromMap(data!);
                      }).toList();

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _headerRow(),
                            const SizedBox(height: 8),
                            ...List.generate(users.length, (index) {
                              return _leaderRow(
                                place: index + 1,
                                user: users[index],
                              );
                            }),
                            const SizedBox(height: 6),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  /* =========================
     UI: Header + Rows
  ========================= */

  Widget _headerRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
      ),
      child: Row(
        children: [
          _headerCell('#', flex: 1),
          const SizedBox(width: 20),
          _headerCell('User', flex: 3),
          const SizedBox(width: 20),
          _headerCell('Lvl', flex: 1),
          const SizedBox(width: 20),
          _headerCell('Rank', flex: 3),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {double? width, int flex = 1}) {
    final w = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: StrokeText(
        text,
        fontSize: 14,
        fillColor: Colors.white,
        strokeColor: Colors.black,
        strokeWidth: 3,
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: w);
    }
    return Expanded(flex: flex, child: w);
  }

  Widget _leaderRow({required int place, required User user}) {
    final double xp = user.xp ?? 0;
    final double rp = user.rp ?? 0;

    final level = PlayerProgress.getLevel(xp);
    final rankData = PlayerProgress.getRank(rp);
    final rankText = '${rankData['rank']} ${rankData['tier']}';

    final bool isTop3 = place <= 3;
    final Color topColor = place == 1
        ? const Color(0xFFFFD700)
        : place == 2
            ? const Color(0xFFC0C0C0)
            : const Color(0xFFCD7F32);

    final double nameSize = isTop3 ? 14 : 12;
    final double strokeW = isTop3 ? 4 : 3;

    final String medal = place == 1
        ? '🏆'
        : place == 2
            ? '🥈'
            : place == 3
                ? '🥉'
                : '';

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(isTop3 ? 0.42 : 0.30),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTop3 ? topColor.withOpacity(0.9) : Colors.white24,
          width: isTop3 ? 2.5 : 2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: StrokeText(
                '$place',
                fontSize: isTop3 ? 16 : 14,
                fillColor: isTop3 ? topColor : Colors.white,
                strokeColor: Colors.black,
                strokeWidth: strokeW,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: StrokeText(
                    '$medal ${user.name ?? 'Player'}',
                    fontSize: nameSize,
                    fillColor: isTop3 ? topColor : Colors.white,
                    strokeColor: Colors.black,
                    strokeWidth: strokeW,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    user.email ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: StrokeText(
                '$level',
                fontSize: isTop3 ? 16 : 14,
                fillColor: isTop3 ? topColor : Colors.yellowAccent,
                strokeColor: Colors.black,
                strokeWidth: strokeW,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 3,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: StrokeText(
                rankText,
                fontSize: isTop3 ? 14 : 12,
                fillColor: isTop3 ? topColor : Colors.white,
                strokeColor: Colors.black,
                strokeWidth: isTop3 ? 4 : 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
