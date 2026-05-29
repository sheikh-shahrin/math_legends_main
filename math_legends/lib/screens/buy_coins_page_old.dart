// lib/screens/buy_coins_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_legends/configs/generic_layout.dart';
import 'package:math_legends/configs/buttons.dart';
import 'package:math_legends/configs/text_stroke.dart';
import 'package:math_legends/controllers/pet_controller.dart';
import 'package:math_legends/services/sound_service.dart';

class BuyCoinsPage extends StatelessWidget {
  const BuyCoinsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final petCtrl = Get.find<PetController>();

    // The pricing options
    final List<Map<String, dynamic>> coinOffers = [
      {'coins': 10, 'price': 0.99},
      {'coins': 25, 'price': 1.99},
      {'coins': 100, 'price': 4.99},
      {'coins': 250, 'price': 9.99},
    ];

    return Obx(
      () {
        final user = petCtrl.user.value!;

        return GenericLayout(
          title: 'Buy Coins',
          solidColor: Colors.blueAccent,
          gradientColor: [Colors.blue[400]!, Colors.blue[700]!],
          strokeColor: Colors.blue[800]!,
          children: [
            _coinHeader(user.coins!, context),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: coinOffers.length,
                itemBuilder: (context, index) {
                  final offer = coinOffers[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.paid,
                          size: 60,
                          color: Colors.yellow,
                        ),
                        const SizedBox(width: 16),

                        /// INFO
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StrokeText(
                                '${offer['coins']} Coins',
                                fontSize: 20,
                                fillColor: Colors.white,
                                strokeColor: Colors.black,
                                strokeWidth: 5,
                              ),
                            ],
                          ),
                        ),

                        /// ACTION BUTTON
                        CustomButton(
                          text: '\$${offer['price']}',
                          gradientColors: [
                            Colors.green,
                            Colors.green[900]!
                          ],
                          textStrokeColor: Colors.black,
                          borderColor: Colors.green[200]!,
                          onPressed: () async {
                            SoundService.playSfx('sounds/purchase.mp3');
                            
                            // Mock Payment execution: Instantly adding coins to the player's account
                            user.coins = user.coins! + (offer['coins'] as int);
                            await petCtrl.firestore.updateUser(user);
                            petCtrl.user.refresh();
                            
                            Get.snackbar(
                              'Payment Successful',
                              'You bought ${offer['coins']} coins!',
                              backgroundColor: Colors.greenAccent,
                              colorText: Colors.black,
                              snackPosition: SnackPosition.TOP,
                              margin: const EdgeInsets.all(15),
                            );
                          },
                          fontSize: 16,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }

  Widget _coinHeader(int coins, BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[800]!, Colors.grey[900]!],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.yellow, width: 5),
          boxShadow: const [
            BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.paid_rounded, size: 30, color: Colors.yellow),
            const SizedBox(width: 8),
            StrokeText(
              coins.toString(),
              fontSize: 22,
              fillColor: Colors.white,
              strokeColor: Colors.black,
              strokeWidth: 4,
            ),
          ],
        ),
      ),
    );
  }
}