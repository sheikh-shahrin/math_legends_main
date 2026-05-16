import 'package:flutter/material.dart';
import 'package:math_legends/configs/background_img.dart';
import 'package:math_legends/configs/pet_overlay.dart';

class HomeLayout extends StatelessWidget {
  final Widget child;

  const HomeLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackgroundImgConfig(child: child),
        const PetOverlay()
      ],
    );
  }
}
