import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  // 1. Changed controller name to match diagram 'userName'
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();

  final Color coralColor = const Color(0xFFFF7F50);
  bool _isLoading = false;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Create User in Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userEmailController.text.trim(),
        password: userPasswordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        "userId": uid,
        "userName": userNameController.text.trim(),
        "userEmail": userEmailController.text.trim(),
        "streakCount": 0,
        "lessonsCompleted": 0,
        "selectedLanguages": ["English"],
        "profileImageUrl": null,
        "createdAt": FieldValue.serverTimestamp(),
      });

      // 3. Success - Close the Page
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account Created!"), backgroundColor: Colors.green),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Auth Error: ${e.message}"), backgroundColor: Colors.red),
      );
    } catch (e) {
      // IF YOU SEE THIS RED BAR, IT MEANS DATABASE PERMISSIONS ARE WRONG
      print("Database Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Database Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDD0),
      appBar: AppBar(
        title: const Text("Create Account", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_add, size: 50, color: coralColor),
                      const SizedBox(height: 16),
                      Text("Join U-Lingo", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: coralColor)),
                      const SizedBox(height: 24),

                      // User Name (Matches diagram 'userName')
                      TextFormField(
                        controller: userNameController,
                        decoration: InputDecoration(
                          labelText: "User Name",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.isEmpty ? "Enter your user name" : null,
                      ),
                      const SizedBox(height: 16),

                      // User Email (Matches diagram 'userEmail')
                      TextFormField(
                        controller: userEmailController,
                        decoration: InputDecoration(
                          labelText: "User Email",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Enter email";
                          if (!value.contains("@siswa.unimas.my") && !value.contains("@unimas.my")) {
                            return "Must be a UNIMAS email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // User Password (Matches diagram 'userPassword')
                      TextFormField(
                        controller: userPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => value!.length < 6 ? "Min 6 chars" : null,
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: coralColor),
                          onPressed: _isLoading ? null : _registerUser,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text("Sign Up", style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                        child: Text("Already have an account? Login", style: TextStyle(color: coralColor)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}