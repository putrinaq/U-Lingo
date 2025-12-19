import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'pages/home_page.dart';
import 'pages/signup_page.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print("✅ Firebase initialized successfully");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'U-Lingo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFFDD0),
        primaryColor: const Color(0xFFFF7F50),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF7F50),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),

      // 1. THIS IS THE KEY CHANGE:
      // We removed 'initialRoute: /'
      // We let 'home' decide where to go start.
      home: const AuthGate(),

      routes: {
        // 2. We REMOVED the '/' route from here.
        // If you keep '/' => HomePage(), it breaks the logic.
        '/home': (_) => const HomePage(),
        '/signup': (_) => const SignUpPage(),
        '/login': (_) => const LoginPage(),
        '/dashboard': (_) => const DashboardPage(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // Debug check
        if (snapshot.connectionState == ConnectionState.active) {
          print("User status: ${snapshot.data?.email}");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          // User is logged in -> Go to Dashboard
          return const DashboardPage();
        }

        // User is NOT logged in -> Go to Home
        return const HomePage();
      },
    );
  }
}