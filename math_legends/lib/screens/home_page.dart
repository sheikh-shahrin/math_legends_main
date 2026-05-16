import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_legends/configs/buttons.dart';
import 'package:math_legends/configs/home_layout.dart';
import 'package:math_legends/configs/logout.dart';
import 'package:math_legends/configs/text_stroke.dart';
import 'package:math_legends/configs/welcome_msg.dart';
import 'package:math_legends/screens/profile_page.dart';
import 'package:math_legends/screens/settings_page.dart';
import 'package:math_legends/screens/shop_page.dart';

import '../controllers/user_controller.dart';
import 'about_page.dart';
import 'chapters_page.dart';
import 'leaderboards_page.dart';

class HomePage extends StatelessWidget {
  final String uid;
  final bool newUser;

  const HomePage({super.key, required this.uid, required this.newUser});

  @override
  Widget build(BuildContext context) {
    final userCtrl = Get.find<UserController>();

    return Obx(
      () {
        final user = userCtrl.user.value;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return HomeLayout(
            child: Padding(
          padding: const EdgeInsets.only(top: 50, bottom: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    width: 250,
                    height: 175,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                                'assets/images/math_legends_logo.png'),
                            fit: BoxFit.cover)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: StrokeText(
                        CustomWelcomeMessages().getMessage(
                            isNewPlayer: newUser,
                            plrName: userCtrl.user.value!.name ?? 'User'),
                        textAlign: TextAlign.center,
                        fontSize: 20,
                        fillColor: Colors.white,
                        strokeWidth: 5,
                        strokeColor: const Color(0xFF0F1220)),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomButton(
                      btnWidth: MediaQuery.of(context).size.width * .625,
                      fontSize: 50,
                      onPressed: () {
                        Get.to(() => const ChaptersPage());
                      },
                      gradientColors: [
                        Colors.lightGreen[400]!,
                        Colors.lightGreen[700]!
                      ],
                      borderColor: Colors.lightGreenAccent[400]!,
                      text: 'Play',
                      textStrokeColor: Colors.lightGreen[900]!),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomRoundButton(
                        onPressed: () {
                          Get.to(() => const ShopPage());
                        },
                        size: 70,
                        iconSize: 40,
                        gradientColors: [
                          Colors.orange[400]!,
                          Colors.orange[700]!
                        ],
                        borderColor: Colors.orangeAccent,
                        icon: Icons.shopping_cart_rounded,
                      ),
                      CustomRoundButton(
                        onPressed: () {
                          Get.to(() => const LeaderboardsPage());
                        },
                        size: 70,
                        iconSize: 40,
                        gradientColors: const [
                          Color(0xFF8D6E63), // Warm brown
                          Color(0xFF5D4037), // Deep brown
                        ],
                        borderColor: Colors.brown[300]!,
                        icon: Icons.leaderboard_rounded,
                      ),
                      CustomRoundButton(
                        onPressed: () {
                          Get.to(() => ProfilePage(userCtrl.user.value!));
                        },
                        size: 70,
                        iconSize: 40,
                        gradientColors: const [
                          Color(0xFF6A11CB),
                          Color(0xFF2575FC)
                        ],
                        borderColor: const Color(0xFF7B61FF),
                        icon: Icons.person,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomRoundButton(
                        onPressed: () {
                          Get.to(() => SettingsPage());
                        },
                        size: 70,
                        iconSize: 40,
                        gradientColors: const [
                          Color(0xFF5FA8FF),
                          Color(0xFF2F6BFF),
                        ],
                        borderColor: const Color(0xFF66B2FF),
                        icon: Icons.settings,
                      ),
                      CustomRoundButton(
                        onPressed: () {
                          Get.to(() => const AboutPage());
                        },
                        size: 70,
                        iconSize: 40,
                        gradientColors: const [
                          Color(0xFF43CEA2),
                          Color(0xFF185A9D)
                        ],
                        borderColor: const Color(0xFF2EE6A6),
                        icon: Icons.info_outline_rounded,
                      ),
                      CustomRoundButton(
                        onPressed: () {
                          LogoutSession.endSession();
                        },
                        size: 70,
                        iconSize: 40,
                        gradientColors: const [
                          Color(0xFFED213A),
                          Color(0xFF93291E)
                        ],
                        borderColor: const Color(0xFFFF3B3B),
                        icon: Icons.logout_rounded,
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ));
      },
    );
  }
}
