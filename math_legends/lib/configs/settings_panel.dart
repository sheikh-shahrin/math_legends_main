import 'package:flutter/material.dart';

class AudioSettingsPanel extends StatelessWidget {
  final Widget child;

  const AudioSettingsPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Expanded(
      child: Container(
        height: size.height,
        width: size.width * 0.9,
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(16),
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
    
        /// ✅ SINGLE SOURCE OF SCROLL
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
