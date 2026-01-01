import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/cat_background.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              /// TITLE
              Text(
                "Choose the language\nyou want to learn!",
                textAlign: TextAlign.center,
                style: GoogleFonts.baloo2(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFE5735C),
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 32),

              _languageButton("🇨🇳", "Mandarin"),
              _languageButton("🇰🇷", "Korean"),
              _languageButton("🇲🇾", "Malay"),
              _languageButton("🇲🇾", "Iban"),
              _languageButton("🇫🇷", "France"),

              const Spacer(),

              /// CONFIRM BUTTON
              _confirmButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Language option button
  Widget _languageButton(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFFF6DDA7),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF3A3A3A),
            width: 2.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3A3A3A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Confirm button
  Widget _confirmButton({required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFF6DDA7),
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
          "Confirm! 🍎",
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF3A3A3A),
          ),
        ),
      ),
    );
  }
}
