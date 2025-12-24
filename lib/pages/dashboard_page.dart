import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ulingo/pages/chatbot_page.dart';
import 'package:ulingo/pages/roadmap_page.dart';
import 'package:ulingo/pages/account_page.dart';
import '../widgets/language_selector.dart'; // Make sure this file exists, or remove if unused

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  String selectedLang = "Mandarin";

  // --- 1. THE HOME TAB (Built right here on the same page) ---
  Widget _buildHomeTab() {
    final user = FirebaseAuth.instance.currentUser;
    final Color coralColor = const Color(0xFFFF7F50);
    final Color cardYellow = const Color(0xFFFFE0B2);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
      builder: (context, snapshot) {

        // Default values
        int streak = 0;
        int lessonsDone = 0;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          streak = data['streakCount'] ?? 0;
          lessonsDone = data['lessonsCompleted'] ?? 0;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // STREAK CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardYellow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(0, 4))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Mascot (Placeholder Icon)
                    const Icon(Icons.pets, size: 80, color: Color(0xFF333333)),

                    // Stats Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Days Streak", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD84315))),
                        Row(
                          children: [
                            Text("$streak", style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w900, color: Color(0xFF333333))),
                            const SizedBox(width: 5),
                            const Icon(Icons.local_fire_department, size: 50, color: Color(0xFFFF5722)),
                          ],
                        ),
                        const Text("You're doing so well!", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const Text("Keep going!", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text("Continue Course", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF333333))),
              const SizedBox(height: 12),

              // COURSE CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 70, width: 70,
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.terrain, size: 40, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Animals", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const Text("Let's learn animals names!", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 8),

                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: (lessonsDone / 15).clamp(0.0, 1.0),
                              backgroundColor: Colors.grey[200],
                              color: coralColor,
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text("$lessonsDone/15", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text("Your Achievements", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF333333))),
              const SizedBox(height: 12),

              // ACHIEVEMENT CARD
              Container(
                width: 130,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 70,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.star, size: 40, color: Colors.orange),
                    ),
                    const SizedBox(height: 8),
                    const Text("The\nAdventurer", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Defines which pages map to which tab index
    final List<Widget> pages = [
      _buildHomeTab(), // 0: Home (Code is above)
      const RoadmapPage(), // 1: Roadmap
      const Center(child: Text("Vocab List (Coming Soon)")), // 2: Vocab
      const ChatbotPage(), // 3: Chatbot
      const AccountPage(), // 4: Account
    ];

    bool isLearningContext = _currentIndex >= 0 && _currentIndex <= 2;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDD0), // Global background cream color

      // --- APP BAR STAYS ---
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7F50),
        title: const Text("U-Lingo"),
        centerTitle: true,
        elevation: 0,

        leading: isLearningContext
            ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2), // Semi-transparent white
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: () {
                // Toggle language logic here
                setState(() {
                  selectedLang = (selectedLang == "Mandarin") ? "English" : "Mandarin";
                });
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Switched to $selectedLang"))
                );
              },
              child: Center(
                child: Text(
                  selectedLang == "Mandarin" ? "CN" : "EN", // Text instead of Flag
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ),
        )
            : null,
      ),

      body: pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFFDD0),
        selectedItemColor: const Color(0xFFFF7F50),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Roadmap"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Vocab"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Chatbot"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
      ),
    );
  }
}