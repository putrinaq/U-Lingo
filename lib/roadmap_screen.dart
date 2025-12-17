import 'package:flutter/material.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final levels = [
      {
        'id': 1,
        'title': 'Level 1: Pinyin Basics',
        'progress': 1.0,
        'completed': true,
        'icon': Icons.music_note,
        'color': Colors.green,
      },
      {
        'id': 2,
        'title': 'Level 2: Basic Greetings',
        'progress': 0.4,
        'completed': false,
        'icon': Icons.waving_hand,
        'color': Colors.blue,
      },
      {
        'id': 3,
        'title': 'Level 3: Numbers',
        'progress': 0.0,
        'completed': false,
        'icon': Icons.numbers,
        'color': Colors.orange,
      },
      {
        'id': 4,
        'title': 'Level 4: Family Members',
        'progress': 0.0,
        'completed': false,
        'icon': Icons.family_restroom,
        'color': Colors.purple,
      },
      {
        'id': 5,
        'title': 'Level 5: Colors',
        'progress': 0.0,
        'completed': false,
        'icon': Icons.palette,
        'color': Colors.pink,
      },
      {
        'id': 6,
        'title': 'Level 6: Food & Drinks',
        'progress': 0.0,
        'completed': false,
        'icon': Icons.restaurant,
        'color': Colors.red,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Roadmap'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          final isLocked = index > 0 && levels[index - 1]['progress'] != 1.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _LevelCard(
              level: level,
              isLocked: isLocked,
              onTap: () {
                if (!isLocked) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LevelDetailScreen(
                        levelId: level['id'] as int,
                        levelTitle: level['title'] as String,
                      ),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final Map<String, dynamic> level;
  final bool isLocked;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = level['progress'] as double;
    final completed = level['completed'] as bool;
    final color = level['color'] as Color;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLocked ? Colors.grey.shade300 : color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLocked ? Icons.lock : level['icon'] as IconData,
                  color: isLocked ? Colors.grey.shade600 : color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level['title'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isLocked ? Colors.grey : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isLocked) ...[
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        completed
                            ? 'Completed'
                            : '${(progress * 100).toInt()}% Complete',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ] else
                      Text(
                        'Complete previous level to unlock',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                completed ? Icons.check_circle : Icons.arrow_forward_ios,
                color: completed ? Colors.green : (isLocked ? Colors.grey : Colors.blue),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// This import is needed for the LevelDetailScreen reference
// In actual implementation, this should be in a separate file
class LevelDetailScreen extends StatelessWidget {
  final int levelId;
  final String levelTitle;

  const LevelDetailScreen({
    super.key,
    required this.levelId,
    required this.levelTitle,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Level Detail')));
  }
}