import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

      // LISTEN TO FIRESTORE COLLECTION
      body: StreamBuilder<QuerySnapshot>(
        // Listen to the "lessons" collection
        stream: FirebaseFirestore.instance.collection('lessons').snapshots(),

        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // 3. No Data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No lessons uploaded by Admin yet."));
          }

          // 4. Data Found! Process the Documents.
          final List<Lesson> lessonList = [];

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;

            // Handle Materials List safely
            List<Map<String, String>> materials = [];
            if (data['materials'] != null) {
              final rawList = data['materials'] as List<dynamic>;
              for (var item in rawList) {
                materials.add({
                  "type": item['type'] ?? 'pdf',
                  "title": item['title'] ?? 'File',
                  "url": item['url'] ?? ''
                });
              }
            }

            lessonList.add(Lesson(
              lessonId: data['lessonId'] ?? doc.id,
              lessonTitle: data['lessonTitle'] ?? 'Untitled',
              associatedSyllabusUnit: data['associatedSyllabusUnit'] ?? '',
              isLocked: data['isLocked'] ?? true, // Firestore boolean
              materials: materials,
            ));
          }

          // Sort by Lesson ID (e.g., "L01", "L02")
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

  // (This Widget stays exactly the same)
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
              leading: const Icon(Icons.description, color: Color(0xFFFF7F50)),
              title: Text(file['title']!),
              trailing: const Icon(Icons.download),
              onTap: () {
                // Open File Logic
              },
            );
          }).toList(), // Removed unnecessary .toList() check
        ],
      ),
    );
  }
}