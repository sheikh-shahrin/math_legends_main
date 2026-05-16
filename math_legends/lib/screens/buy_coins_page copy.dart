// lib/screens/buy_coins_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_legends/configs/generic_layout.dart';
import 'package:math_legends/configs/buttons.dart';
import 'package:math_legends/configs/text_stroke.dart';
import 'package:math_legends/controllers/pet_controller.dart';
import '../controllers/iap_controller.dart'; // <--- IMPORT IAP CONTROLLER

class BuyCoinsPage extends StatelessWidget {
  const BuyCoinsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final petCtrl = Get.find<PetController>();
    
    // Initialize the IAP Controller when this page is opened
    final iapCtrl = Get.put(IapController());

    return GenericLayout(
      title: 'Buy Coins',
      solidColor: Colors.blueAccent,
      gradientColor: [Colors.blue[400]!, Colors.blue[700]!],
      strokeColor: Colors.blue[800]!,
      children: [
        Obx(() {
          final user = petCtrl.user.value;
          return _coinHeader(user?.coins ?? 0, context);
        }),
        const SizedBox(height: 16),
        
        Expanded(
          child: Obx(() {
            // Loading state while fetching from Play Store
            if (!iapCtrl.isAvailable.value) {
              return const Center(
                child: Text(
                  'Store unavailable.\nPlease check your connection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            if (iapCtrl.products.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Colors.yellow));
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: iapCtrl.products.length,
              itemBuilder: (context, index) {
                final product = iapCtrl.products[index];

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
                              product.title.replaceAll('(Math Legends)', '').trim(), // Cleans up default Play Store title
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
                        text: product.price, // Automatically formats local currency symbol (e.g. $0.99, €0.99)
                        gradientColors: [
                          Colors.green,
                          Colors.green[900]!
                        ],
                        textStrokeColor: Colors.black,
                        borderColor: Colors.green[200]!,
                        onPressed: () {
                          // Triggers the real Google Play checkout
                          iapCtrl.buyCoins(product);
                        },
                        fontSize: 16,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        )
      ],
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