import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              //mascot section
              Image.asset(
                'assets/images/logo.jpg',
                height: 180,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.pets, size: 100, color: Color(0xFFFF7F50));
                },
              ),

              const SizedBox(height: 32),

              Text(
                "U-Lingo",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),

              const Text("U-Lingo",
                style: TextStyle(
                    fontSize:40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),


              const SizedBox(height: 60),


              _button(context, "Create Account", Icons.person_add, '/signup'),
              const SizedBox(height: 16),
              _button(context, "Login", Icons.login, '/login'),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }


  Widget _button(
      BuildContext context,
      String text,
      IconData icon,
      String route,
      ) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: Icon(icon),
              label: Text(text, style: const TextStyle(fontSize: 18)),
              onPressed: () => Navigator.pushNamed(context, route),
            ),
          );
      }
}
