import 'package:flutter/material.dart';

class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample vocabulary data for different levels
    final vocabularyWords = [
      {
        'word': '你好',
        'pinyin': 'nǐ hǎo',
        'translation': 'Hello',
        'category': 'Greetings',
      },
      {
        'word': '再见',
        'pinyin': 'zài jiàn',
        'translation': 'Goodbye',
        'category': 'Greetings',
      },
      {
        'word': '谢谢',
        'pinyin': 'xiè xie',
        'translation': 'Thank you',
        'category': 'Greetings',
      },
      {
        'word': '对不起',
        'pinyin': 'duì bu qǐ',
        'translation': 'Sorry',
        'category': 'Greetings',
      },
      {
        'word': '早上好',
        'pinyin': 'zǎo shàng hǎo',
        'translation': 'Good morning',
        'category': 'Greetings',
      },
      {
        'word': '晚安',
        'pinyin': 'wǎn ān',
        'translation': 'Good night',
        'category': 'Greetings',
      },
      {
        'word': '请',
        'pinyin': 'qǐng',
        'translation': 'Please',
        'category': 'Greetings',
      },
      {
        'word': '不客气',
        'pinyin': 'bù kè qi',
        'translation': 'You\'re welcome',
        'category': 'Greetings',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.book, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap on any word to hear its pronunciation',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vocabularyWords.length,
              itemBuilder: (context, index) {
                final word = vocabularyWords[index];
                return _VocabularyCard(
                  word: word['word']!,
                  pinyin: word['pinyin']!,
                  translation: word['translation']!,
                  category: word['category']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabularyCard extends StatelessWidget {
  final String word;
  final String pinyin;
  final String translation;
  final String category;

  const _VocabularyCard({
    required this.word,
    required this.pinyin,
    required this.translation,
    required this.category,
  });

  void _playSound(BuildContext context) {
    // Simulate audio playback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing pronunciation: $word ($pinyin)'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _playSound(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    word,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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
                      pinyin,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      translation,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _playSound(context),
                icon: Icon(
                  Icons.volume_up,
                  color: Colors.blue.shade700,
                ),
                iconSize: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}