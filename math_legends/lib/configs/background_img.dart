import 'package:flutter/material.dart';

class BackgroundImgConfig extends StatelessWidget {
  final Widget child;
  final AppBar? appBar;

  const BackgroundImgConfig({super.key, required this.child, this.appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/math_legends_background.gif'),
                fit: BoxFit.cover,)),
        child: child,
      ),
    );
  }
}
