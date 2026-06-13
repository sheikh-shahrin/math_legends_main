import 'package:flutter/material.dart';
import 'package:math_legends/services/sound_service.dart';
import 'package:math_legends/configs/text_stroke.dart';

// Custom Button
class CustomButton extends StatefulWidget {
  final VoidCallback onPressed;
  final List<Color> gradientColors;
  final Color borderColor;
  final Color textStrokeColor;
  final String text;
  final double? btnWidth;
  final double? btnHeight;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.gradientColors,
    required this.borderColor,
    required this.text,
    required this.textStrokeColor,
    this.btnWidth,
    this.btnHeight,
    this.fontSize = 25, this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: (_) => setState(() => _scale = 1.0),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.9),
        onTapUp: (_) {
          SoundService.playSfx('sounds/button_click.mp3');
          setState(() => _scale = 1.0);
        },
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
              width: widget.btnWidth,
              height: widget.btnHeight,
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: widget.gradientColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(
                  color: widget.borderColor,
                  width: 5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.borderColor,
                    offset: const Offset(0, 4),
                    blurRadius: 6,
                  ),
                ],
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Center(
                  child: StrokeText(
                    widget.text,
                    fontSize: widget.fontSize,
                    fillColor: Colors.white,
                    strokeColor: widget.textStrokeColor,
                    strokeWidth: 5,
                  ),
                ),
              )),
        ),
      ),
    );
  }
}

// Custom Round Icon Button
class CustomRoundButton extends StatefulWidget {
  final VoidCallback onPressed;
  final List<Color> gradientColors;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final double size;
  final double iconSize;

  const CustomRoundButton({
    super.key,
    required this.onPressed,
    required this.gradientColors,
    required this.borderColor,
    required this.icon,
    this.iconColor = Colors.white,
    this.size = 64,
    this.iconSize = 28,
  });

  @override
  State<CustomRoundButton> createState() => _CustomRoundButtonState();
}

class _CustomRoundButtonState extends State<CustomRoundButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: (_) => setState(() => _scale = 1.0),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.9),
        onTapUp: (_) {
          SoundService.playSfx('sounds/button_click.mp3');
          setState(() => _scale = 1.0);
        },
        onTapCancel: () => setState(() => _scale = 1.0),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: widget.gradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border.all(
                color: widget.borderColor,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.borderColor,
                  offset: const Offset(0, 4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                widget.icon,
                size: widget.iconSize,
                color: widget.iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Text Field
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final List<Color> gradientColors;
  final Color borderColor;
  final Color iconColor;
  final RegExp regExp;
  final TextInputType textInputType;
  final bool validate;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    required this.gradientColors,
    required this.borderColor,
    required this.iconColor,
    required this.regExp,
    required this.textInputType,
    required this.validate,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String errorMsg = 'An error has occurred';
  bool noError = false;

  @override
  Widget build(BuildContext context) {
    if (widget.textInputType == TextInputType.emailAddress) {
      errorMsg = 'Please enter valid email';
    } else if (widget.textInputType == TextInputType.visiblePassword) {
      errorMsg = 'Password must be at least 8 characters';
    } else if (widget.textInputType == TextInputType.name) {
      errorMsg = 'Name must not contain special characters';
    }

    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: widget.gradientColors,
        ),
        border: Border.all(
          color: widget.borderColor,
          width: 5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.borderColor,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            widget.icon,
            color: widget.iconColor,
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: widget.controller,
                  obscureText: widget.obscureText,
                  keyboardType: widget.textInputType,
                  validator: widget.validate
                      ? (value) {
                          setState(() {
                            noError = !widget.regExp.hasMatch(value!) &&
                                value.isNotEmpty;
                          });
                          if (noError) {
                            return errorMsg;
                          } else {
                            return null;
                          }
                        }
                      : null,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: noError
                        ? const EdgeInsets.only(top: 10)
                        : const EdgeInsets.symmetric(vertical: 10),
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    errorStyle: const TextStyle(
                      color: Colors.yellowAccent,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      height: 1.3,
                    ),
                    errorMaxLines: 3,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
                SizedBox(
                  height: noError ? 5 : 0,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Square Text Container
class SquareTextContainer extends StatelessWidget {
  final String text;
  final double size;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final TextStyle textStyle;
  final EdgeInsets padding;

  const SquareTextContainer({
    super.key,
    required this.text,
    this.size = 80,
    required this.backgroundColor,
    required this.borderColor,
    this.borderWidth = 4,
    required this.textStyle,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      // --- WRAPPED IN FITTEDBOX HERE ---
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: textStyle,
        ),
      ),
    );
  }
}
