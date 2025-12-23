import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'level_detail_screen.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Roadmap'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final completedLevels = List<int>.from(userData['completedLevels'] ?? []);
          final currentLevel = userData['currentLevel'] ?? 1;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('levels')
                .orderBy('levelId')
                .snapshots(),
            builder: (context, levelsSnapshot) {
              if (levelsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!levelsSnapshot.hasData || levelsSnapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No levels available yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please wait while the admin sets up the course',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              final levels = levelsSnapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final levelDoc = levels[index];
                  final levelData = levelDoc.data() as Map<String, dynamic>;
                  final levelId = levelData['levelId'] as int;
                  final isCompleted = completedLevels.contains(levelId);
                  final isLocked = levelId > currentLevel;
                  final isCurrent = levelId == currentLevel;

                  return _LevelCard(
                    levelDocId: levelDoc.id,
                    levelData: levelData,
                    isCompleted: isCompleted,
                    isLocked: isLocked,
                    isCurrent: isCurrent,
                    onTap: isLocked
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LevelDetailScreen(
                            levelDocId: levelDoc.id,
                            levelId: levelId,
                            levelTitle: levelData['title'] ?? 'Untitled',
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String levelDocId;
  final Map<String, dynamic> levelData;
  final bool isCompleted;
  final bool isLocked;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _LevelCard({
    Key? key,
    required this.levelDocId,
    required this.levelData,
    required this.isCompleted,
    required this.isLocked,
    required this.isCurrent,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    IconData iconData;
    Color iconColor;

    if (isCompleted) {
      cardColor = Colors.green[50]!;
      iconData = Icons.check_circle;
      iconColor = Colors.green;
    } else if (isCurrent) {
      cardColor = Colors.blue[50]!;
      iconData = Icons.play_circle;
      iconColor = Colors.blue;
    } else if (isLocked) {
      cardColor = Colors.grey[200]!;
      iconData = Icons.lock;
      iconColor = Colors.grey;
    } else {
      cardColor = Colors.orange[50]!;
      iconData = Icons.play_arrow;
      iconColor = Colors.orange;
    }

    final quizCount = (levelData['quizzes'] as List?)?.length ?? 0;
    final pronunciationCount = (levelData['pronunciations'] as List?)?.length ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrent ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${levelData['levelId']}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      levelData['title'] ?? 'Untitled',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Colors.grey : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      levelData['description'] ?? 'No description',
                      style: TextStyle(
                        fontSize: 14,
                        color: isLocked ? Colors.grey : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.quiz, size: 14, color: Colors.blue[700]),
                        const SizedBox(width: 4),
                        Text(
                          '$quizCount',
                          style: TextStyle(
                            fontSize: 12,
                            color: isLocked ? Colors.grey : Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.mic, size: 14, color: Colors.purple[700]),
                        const SizedBox(width: 4),
                        Text(
                          '$pronunciationCount',
                          style: TextStyle(
                            fontSize: 12,
                            color: isLocked ? Colors.grey : Colors.purple[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (isCurrent)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Continue here',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                iconData,
                size: 32,
                color: iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}