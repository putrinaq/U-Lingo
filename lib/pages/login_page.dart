import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/cat_background.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 70),

              /// TITLE
              Text(
                "Login",
                style: GoogleFonts.baloo2(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFE5735C),
                ),
              ),

              const SizedBox(height: 36),

              /// INPUT FIELDS
              _inputField(hint: "Email"),
              const SizedBox(height: 18),
              _inputField(hint: "Password", obscure: true),

              const SizedBox(height: 12),

              /// FORGOT PASSWORD (placeholder)
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    // TODO: Reset password page (later)
                  },
                  child: Text(
                    "Forgot password",
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3A3A3A),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const Spacer(),


              const SizedBox(height: 24),

              /// LOGIN BUTTON
              _loginButton(
                onPressed: () {
                  // TODO: Firebase login later
                  Navigator.pushNamed(context, '/home');
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

  /// Login button
  Widget _loginButton({required VoidCallback onPressed}) {
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
          "Login 🍎",
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
