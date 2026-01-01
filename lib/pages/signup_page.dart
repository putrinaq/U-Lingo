import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/cat_background.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),

              /// TITLE
              Text(
                "Sign Up",
                style: GoogleFonts.baloo2(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFE5735C),
                ),
              ),

              const SizedBox(height: 32),

              /// INPUT FIELDS
              _inputField(hint: "Email"),
              const SizedBox(height: 18),
              _inputField(hint: "Name"),
              const SizedBox(height: 18),
              _inputField(hint: "Password", obscure: true),

              const Spacer(),


              const SizedBox(height: 24),

              /// CONFIRM BUTTON
              _confirmButton(
                onPressed: () {
                  // TODO: add Firebase later
                  Navigator.pushNamed(context, '/email-verify');
                },
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  /// Rounded input field
  Widget _inputField({
    required String hint,
    bool obscure = false,
  }) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F1C8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF3A3A3A),
          width: 2.5,
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        obscureText: obscure,
        style: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF3A3A3A),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black45,
          ),
          border: InputBorder.none,
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
