import 'package:flutter/material.dart';

// Pages
import 'pages/splash_page.dart';
import 'pages/home_page.dart';
import 'pages/signup_page.dart';
import 'pages/login_page.dart';
import 'pages/email_verify_page.dart';
import 'pages/email_verified_page.dart';
import 'pages/languages_selection.dart';
import 'pages/chatbot_page.dart';
import 'pages/roadmap_page.dart';
import 'pages/practice_page1.dart';
import 'pages/vocabulary_page.dart';
import 'pages/profile_page.dart';

void main() {
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
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9F5E9),
      ),

      /// Start here
      initialRoute: '/splash',

      routes: {
        '/splash': (_) => const SplashPage(),
        '/home': (_) => const HomePage(),
        '/signup': (_) => const SignUpPage(),
        '/login': (_) => const LoginPage(),

        '/email-verify': (_) => const EmailVerifyPage(),
        '/email-verified': (_) => const EmailVerifiedPage(),

        '/language-select': (_) => const LanguageSelectionPage(),
        '/chatbot': (_) => const ChatbotPage(),

        '/roadmap': (_) => const RoadmapPage(),
        '/practice1': (_) => const PracticePage1(),
        '/vocabulary': (_) => const VocabularyPage(),
        '/profile': (_) => const ProfilePage(),
      },
    );
  }
}
