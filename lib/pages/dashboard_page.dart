import 'package:flutter/material.dart';
import 'package:ulingo/pages/chatbot_page.dart';
import 'package:ulingo/pages/roadmap_page.dart';
import 'package:ulingo/pages/account_page.dart';
import '../widgets/language_selector.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  // Matches 'selectedLanguages' attribute in your class diagram
  String selectedLang = "Mandarin";

  final List<Widget> _tabs = [
    const Center(child: Text("Home Feed (Coming Soon)")),
    const RoadmapPage(),
    const Center(child: Text("Vocab List (Coming Soon)")),
    const ChatbotPage(),
    const AccountPage(), // logout() is strictly inside this page
  ];

  @override
  Widget build(BuildContext context) {
    // SE Logic: Language selector is only for learning-context pages
    bool isLearningContext = _currentIndex >= 0 && _currentIndex <= 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7F50),
        title: const Text("U-Lingo"),
        centerTitle: true,
        elevation: 0,
        // ✅ Language selector is isolated from Chatbot/Account
        leading: isLearningContext
            ? LanguageSelector(
          currentLanguage: selectedLang,
          onLanguageChanged: (newLang) {
            if (newLang == 'English') {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("English mode coming soon!"))
              );
            } else {
              setState(() => selectedLang = newLang);
            }
          },
        )
            : null,
      ),
      body: _tabs[_currentIndex],
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