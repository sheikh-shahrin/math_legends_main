import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_legends/configs/pet_overlay.dart';
import 'text_stroke.dart';

import 'background_img.dart';
import 'buttons.dart';

class GenericLayout extends StatelessWidget {
  final String title;
  final Color solidColor;
  final Color strokeColor;
  final List<Color> gradientColor;
  final List<Widget> children;

  const GenericLayout(
      {super.key,
      required this.title,
      this.solidColor = Colors.black,
      required this.gradientColor,
      required this.children,
      this.strokeColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackgroundImgConfig(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomRoundButton(
                    onPressed: () {
                      Get.back(result: true);
                    },
                    size: 50,
                    iconSize: 30,
                    gradientColors: gradientColor,
                    borderColor: solidColor,
                    icon: Icons.arrow_back_rounded,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: StrokeText(
                      title,
                      fontSize: 30,
                      fillColor: Colors.white,
                      strokeColor: strokeColor,
                      strokeWidth: 5,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              ...children
            ],
          ),
        )),
        const PetOverlay()
      ],
    );
  }
}
