import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_legends/configs/generic_layout.dart';

import '../configs/buttons.dart';
import '../configs/text_stroke.dart';
import '../controllers/pet_controller.dart';
import '../utils/game_data.dart';

import 'buy_coins_page_old.dart'; 

class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final petCtrl = Get.find<PetController>();

    return Obx(
      () {
        final user = petCtrl.user.value!;
        const pets = GameData.pets;

        return GenericLayout(
          title: 'Pet Shop',
          solidColor: Colors.orangeAccent,
          gradientColor: [Colors.orange[400]!, Colors.orange[700]!],
          strokeColor: Colors.orange[800]!,
          children: [
            _coinHeader(user.coins!, context),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  final stats = user.petData!.petData![pet]!;

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
                        Image.asset(
                          'assets/gifs/${pet.gif}',
                          width: 80,
                          height: 80,
                        ),
                        const SizedBox(width: 16),

                        /// INFO
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StrokeText(
                                pet.name,
                                fontSize: 18,
                                fillColor: Colors.white,
                                strokeColor: Colors.black,
                                strokeWidth: 5,
                              ),
                              const SizedBox(height: 4),
                              StrokeText(
                                'x${pet.multiplier} rewards',
                                fontSize: 15,
                                fillColor: Colors.yellow,
                                strokeColor: Colors.black,
                                strokeWidth: 3,
                              ),
                            ],
                          ),
                        ),

                        /// ACTION BUTTON
                        if (!stats.discovered!)
                          CustomButton(
                            text: '${pet.cost} Coins',
                            gradientColors: [
                              Colors.orange,
                              Colors.orange[900]!
                            ],
                            textStrokeColor: Colors.black,
                            borderColor: Colors.orange[200]!,
                            onPressed: () => petCtrl.buyPet(pet, context),
                            fontSize: 15,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                          )
                        else if (stats.equipped!)
                          const StrokeText(
                            'EQUIPPED',
                            fontSize: 17.5,
                            strokeColor: Colors.black,
                            fillColor: Colors.greenAccent,
                          )
                        else
                          CustomButton(
                            text: 'Equip',
                            gradientColors: [Colors.green, Colors.green[900]!],
                            textStrokeColor: Colors.black,
                            borderColor: Colors.green[200]!,
                            fontSize: 15,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            onPressed: () => petCtrl.equipPet(pet),
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
        margin: const EdgeInsets.only(bottom: 16), // Gives padding to the bottom list
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey[800]!,
              Colors.grey[900]!,
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.yellow, width: 5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.paid_rounded,
              size: 30,
              color: Colors.yellow,
            ),
            const SizedBox(width: 8),
            StrokeText(
              coins.toString(),
              fontSize: 22,
              fillColor: Colors.white,
              strokeColor: Colors.black,
              strokeWidth: 4,
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                // <--- Navigates to the buy coins page
                Get.to(() => const BuyCoinsPage());
              },
              child: const Icon(
                Icons.add_circle,
                color: Colors.greenAccent,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
