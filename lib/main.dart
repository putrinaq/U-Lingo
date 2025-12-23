import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ulingo/screens/welcome_page.dart';
import 'screens/language_selection_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/verify_email_page.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_verify_email_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ULingoApp());
}

class ULingoApp extends StatelessWidget {
  const ULingoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'U-Lingo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print('=== AUTH WRAPPER DEBUG ===');
        print('Connection state: ${snapshot.connectionState}');
        print('Has data: ${snapshot.hasData}');

        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('State: WAITING');
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        // User is not logged in - show welcome screen
        if (!snapshot.hasData) {
          print('State: NO USER - Showing WelcomePage');
          return const WelcomePage();
        }

        final user = snapshot.data!;
        print('User ID: ${user.uid}');
        print('User Email: ${user.email}');
        print('Email Verified: ${user.emailVerified}');

        // ============================================
        // STEP 1: Check if email is verified
        // ============================================
        if (!user.emailVerified) {
          print('State: EMAIL NOT VERIFIED');

          // Check if this is an admin or student
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('admins')
                .doc(user.uid)
                .get(),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                print('Admin check: WAITING');
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final isAdmin = adminSnapshot.hasData && adminSnapshot.data!.exists;
              print('Is Admin: $isAdmin');

              if (isAdmin) {
                print('→ Showing: AdminVerifyEmailPage');
                return const AdminVerifyEmailPage();
              } else {
                print('→ Showing: VerifyEmailPage (Student)');
                return const VerifyEmailPage();
              }
            },
          );
        }

        // ============================================
        // STEP 2: Email is verified - Check domain
        // ============================================
        print('State: EMAIL VERIFIED ✓');

        if (!user.email!.endsWith('@siswa.unimas.my')) {
          print('ERROR: INVALID DOMAIN - ${user.email}');
          print('→ Showing: Invalid Domain Error Screen');

          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 80,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Invalid Email Domain',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Only UNIMAS email addresses (@siswa.unimas.my) are allowed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        print('Domain valid: @siswa.unimas.my ✓');

        // ============================================
        // STEP 3: Check if user is ADMIN
        // ============================================
        print('Checking if user is admin...');

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('admins')
              .doc(user.uid)
              .get(),
          builder: (context, adminSnapshot) {
            if (adminSnapshot.connectionState == ConnectionState.waiting) {
              print('Admin document check: WAITING');
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Checking account type...'),
                    ],
                  ),
                ),
              );
            }

            final adminExists = adminSnapshot.hasData && adminSnapshot.data!.exists;
            print('Admin document exists: $adminExists');

            if (adminExists) {
              print('✓✓✓ USER IS ADMIN ✓✓✓');
              print('Admin data: ${adminSnapshot.data!.data()}');
              print('→ Showing: AdminDashboardScreen');
              return const AdminDashboardScreen();
            }

            // ============================================
            // STEP 4: Not admin - Check STUDENT profile
            // ============================================
            print('User is NOT admin - treating as student');
            print('Checking student profile...');

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  print('User document check: WAITING');
                  return const Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading profile...'),
                        ],
                      ),
                    ),
                  );
                }

                final userExists = userSnapshot.hasData && userSnapshot.data!.exists;
                print('User document exists: $userExists');

                if (userExists) {
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  print('User data: $userData');

                  final hasLanguage = userData.containsKey('selectedLanguage') &&
                      userData['selectedLanguage'] != null &&
                      userData['selectedLanguage'].toString().isNotEmpty;
                  print('Has selected language: $hasLanguage');
                  print('Language value: ${userData['selectedLanguage']}');

                  if (hasLanguage) {
                    print('✓✓✓ STUDENT WITH LANGUAGE ✓✓✓');
                    print('→ Showing: DashboardScreen');
                    return const DashboardScreen();
                  } else {
                    print('Student has profile but NO language selected');
                    print('→ Showing: LanguageSelectionScreen');
                    return const LanguageSelectionScreen();
                  }
                } else {
                  print('No user document found - First time login');
                  print('✓✓✓ SHOWING LANGUAGE SELECTION ✓✓✓');
                  print('→ Showing: LanguageSelectionScreen');
                  return const LanguageSelectionScreen();
                }
              },
            );
          },
        );
      },
    );
  }
}
