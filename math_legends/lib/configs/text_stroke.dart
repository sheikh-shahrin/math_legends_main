import 'package:flutter/material.dart';

class StrokeText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final FontWeight fontWeight;
  final TextAlign? textAlign;

  const StrokeText(
    this.text, {
    super.key,
    required this.fontSize,
    required this.fillColor,
    required this.strokeColor,
    this.strokeWidth = 3,
    this.fontWeight = FontWeight.w800,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        Text(
          text,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: fillColor,
          ),
        ),
      ],
    );
  }
}
