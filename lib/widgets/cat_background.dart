import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Base background color
        Container(
          color: const Color(0xFFF9F5E9),
        ),

        /// Responsive background image
        Center(
          child: AspectRatio(
            aspectRatio: 9 / 19.5, // 📱 phone ratio
            child: Image.asset(
              'assets/images/cat_background.png',
              fit: BoxFit.cover,
            ),
          ),
        ),

        /// Page content
        SafeArea(child: child),
      ],
    );
  }
}
