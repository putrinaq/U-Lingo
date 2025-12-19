import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // <--- CHANGED IMPORT
import '../models/lesson_model.dart';

class RoadmapPage extends StatelessWidget {
  const RoadmapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Learning Path"),
        backgroundColor: const Color(0xFFFFFDD0),
        automaticallyImplyLeading: false,
      ),

      // LISTEN TO REALTIME DATABASE
      body: StreamBuilder<DatabaseEvent>(
        // Listen to the "lessons" node in the JSON tree
        stream: FirebaseDatabase.instance.ref('lessons').onValue,

        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // 3. No Data (Empty or doesn't exist yet)
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No lessons uploaded by Admin yet."));
          }

          // 4. Data Found! Process the JSON Map.
          // Realtime DB returns a Map<dynamic, dynamic>, not a List.
          final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          // Convert the Map values into a List of Lessons
          final List<Lesson> lessonList = [];

          data.forEach((key, value) {
            final lessonData = Map<String, dynamic>.from(value);

            // Handle Materials List safely
            List<Map<String, String>> materials = [];
            if (lessonData['materials'] != null) {
              // Realtime DB stores lists as Lists of Objects
              final rawList = lessonData['materials'] as List<dynamic>;
              for (var item in rawList) {
                materials.add({
                  "type": item['type'] ?? 'pdf',
                  "title": item['title'] ?? 'File',
                  "url": item['url'] ?? ''
                });
              }
            }

            lessonList.add(Lesson(
              lessonId: lessonData['lessonId'] ?? key,
              lessonTitle: lessonData['lessonTitle'] ?? 'Untitled',
              associatedSyllabusUnit: lessonData['associatedSyllabusUnit'] ?? '',
              isLocked: lessonData['isLocked'] ?? true,
              materials: materials,
            ));
          });

          // Sort by Lesson ID (so Lesson 1 comes before Lesson 2)
          lessonList.sort((a, b) => a.lessonId.compareTo(b.lessonId));

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: lessonList.length,
            itemBuilder: (context, index) {
              return _buildExpandableLessonCard(context, lessonList[index]);
            },
          );
        },
      ),
    );
  }

  // Same UI Widget as before
  Widget _buildExpandableLessonCard(BuildContext context, Lesson lesson) {
    final bool isLocked = lesson.isLocked;

    return Card(
      elevation: isLocked ? 1 : 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isLocked ? Colors.grey.shade100 : Colors.white,

      child: ExpansionTile(
        leading: Icon(
            isLocked ? Icons.lock : Icons.menu_book,
            color: isLocked ? Colors.grey : const Color(0xFF9DC183)
        ),
        title: Text(
          lesson.lessonTitle,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isLocked ? Colors.grey : Colors.black87
          ),
        ),
        subtitle: Text(lesson.associatedSyllabusUnit),
        enabled: !isLocked,
        children: [
          if (lesson.materials.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("No materials uploaded yet."),
            ),
          ...lesson.materials.map((file) {
            return ListTile(
              leading: Icon(Icons.description, color: Color(0xFFFF7F50)),
              title: Text(file['title']!),
              trailing: const Icon(Icons.download),
              onTap: () {
                // Open File Logic
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}