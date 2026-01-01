import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatbotPage extends StatelessWidget {
  const ChatbotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5E9),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  /// TITLE IMAGE
                  Image.asset(
                    'assets/images/welcome_font.png',
                    height: 130, // 🔥 reduced
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "by University of Malaysia Sarawak",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// MAIN ILLUSTRATION
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/welcome_cat.png',
                        height: 280,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  /// BUTTONS
                  if (user == null) ...[
                    _figmaButton(
                      text: "Sign Up",
                      onPressed: () =>
                          Navigator.pushNamed(context, '/signup'),
                    ),
                    const SizedBox(height: 16),
                    _figmaButton(
                      text: "Login",
                      onPressed: () =>
                          Navigator.pushNamed(context, '/login'),
                    ),
                  ] else ...[
                    _figmaButton(
                      text: "Continue",
                      onPressed: () =>
                          Navigator.pushNamed(context, '/service'),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Figma-style button
  Widget _figmaButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFDF8D8),
          side: const BorderSide(
            color: Color(0xFF3A3A3A),
            width: 2.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3A3A3A),
          ),
        ),
      ),
    );
  }
}
