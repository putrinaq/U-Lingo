import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  bool _isLoading = false;
  String? _selectedLanguage;

  Future<void> _confirmLanguage() async {
    if (_selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a language first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final currentUser = FirebaseAuth.instance.currentUser!;

      print('=== LANGUAGE SELECTION ===');
      print('User ID: $userId');
      print('Selected Language: $_selectedLanguage');

      // Check if user document exists
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        // This should rarely happen since login_screen creates the document
        // But we handle it as a fallback
        print('User document does not exist, creating new one');
        final now = DateTime.now();
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'name': currentUser.displayName ?? 'Student',
          'email': currentUser.email ?? '',
          'selectedLanguage': _selectedLanguage,
          'streak': 0,
          'lastAccessDate': now.toIso8601String(),
          'currentLevel': 1,
          'completedLevels': [],
          'achievements': [],
          'createdAt': Timestamp.fromDate(now),
        });
        print('✅ New user document created with name: ${currentUser.displayName}');
      } else {
        // Document exists - just update the language
        // DO NOT overwrite existing fields like 'name'
        print('User document exists, updating language only');
        final existingData = userDoc.data() as Map<String, dynamic>;
        print('Existing name in document: ${existingData['name']}');

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'selectedLanguage': _selectedLanguage,
        });
        print('✅ Language updated to: $_selectedLanguage');
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      print('❌ Error in language selection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF5F0),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '12:30',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // Decorative elements
          Positioned(
            top: 20,
            left: 20,
            child: _buildApple(),
          ),
          Positioned(
            top: 40,
            right: 30,
            child: _buildStar(),
          ),
          Positioned(
            top: 10,
            right: 100,
            child: _buildApple(),
          ),
          Positioned(
            bottom: 200,
            right: 20,
            child: _buildApple(),
          ),
          Positioned(
            bottom: 250,
            left: 30,
            child: _buildStar(),
          ),
          Positioned(
            bottom: 120,
            left: 20,
            child: _buildOwl(),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'Choose the language\nyou want to learn!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B6B),
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          _LanguageCard(
                            language: 'Mandarin',
                            flag: '🇨🇳',
                            isSelected: _selectedLanguage == 'Mandarin',
                            onTap: () => setState(() => _selectedLanguage = 'Mandarin'),
                          ),
                          const SizedBox(height: 16),
                          _LanguageCard(
                            language: 'Korean',
                            flag: '🇰🇷',
                            isSelected: _selectedLanguage == 'Korean',
                            onTap: () => setState(() => _selectedLanguage = 'Korean'),
                          ),
                          const SizedBox(height: 16),
                          _LanguageCard(
                            language: 'Malay',
                            flag: '🇲🇾',
                            isSelected: _selectedLanguage == 'Malay',
                            onTap: () => setState(() => _selectedLanguage = 'Malay'),
                          ),
                          const SizedBox(height: 16),
                          _LanguageCard(
                            language: 'Iban',
                            flag: '🇲🇾',
                            isSelected: _selectedLanguage == 'Iban',
                            onTap: () => setState(() => _selectedLanguage = 'Iban'),
                          ),
                          const SizedBox(height: 16),
                          _LanguageCard(
                            language: 'France',
                            flag: '🇫🇷',
                            isSelected: _selectedLanguage == 'France',
                            onTap: () => setState(() => _selectedLanguage = 'France'),
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Confirm button
          Positioned(
            bottom: 30,
            left: 32,
            right: 32,
            child: GestureDetector(
              onTap: _confirmLanguage,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D4),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFF8B6914),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Confirm!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B6914),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('🍎', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApple() {
    return const Text('🍎', style: TextStyle(fontSize: 32));
  }

  Widget _buildStar() {
    return const Text('⭐', style: TextStyle(fontSize: 24));
  }

  Widget _buildOwl() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text('🦉', style: TextStyle(fontSize: 40)),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String language;
  final String flag;
  final bool isSelected;
  final VoidCallback? onTap;

  const _LanguageCard({
    Key? key,
    required this.language,
    required this.flag,
    required this.isSelected,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFE8B3) : const Color(0xFFFFF3D4),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFF8B6914),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                language,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3D2817),
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}