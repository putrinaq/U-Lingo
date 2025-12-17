import 'package:flutter/material.dart';

class LevelDetailScreen extends StatefulWidget {
  final int levelId;
  final String levelTitle;

  const LevelDetailScreen({
    super.key,
    required this.levelId,
    required this.levelTitle,
  });

  @override
  State<LevelDetailScreen> createState() => _LevelDetailScreenState();
}

class _LevelDetailScreenState extends State<LevelDetailScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;
  String? _selectedAnswer;
  bool _answerChecked = false;

  // Sample quiz data
  final List<Map<String, dynamic>> _quizQuestions = [
    {
      'audio': '你好',
      'question': 'What does this audio say?',
      'options': ['你好 (nǐ hǎo)', '再见 (zài jiàn)', '谢谢 (xiè xie)', '对不起 (duì bu qǐ)'],
      'correct': '你好 (nǐ hǎo)',
      'translation': 'Hello',
    },
    {
      'audio': '谢谢',
      'question': 'Choose the correct Mandarin word:',
      'options': ['你好 (nǐ hǎo)', '谢谢 (xiè xie)', '再见 (zài jiàn)', '早上好 (zǎo shàng hǎo)'],
      'correct': '谢谢 (xiè xie)',
      'translation': 'Thank you',
    },
    {
      'audio': '再见',
      'question': 'Select the matching word:',
      'options': ['再见 (zài jiàn)', '你好 (nǐ hǎo)', '晚安 (wǎn ān)', '对不起 (duì bu qǐ)'],
      'correct': '再见 (zài jiàn)',
      'translation': 'Goodbye',
    },
  ];

  void _playAudio() {
    // Simulate audio playback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing audio: ${_quizQuestions[_currentQuestionIndex]['audio']}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _checkAnswer() {
    if (_selectedAnswer == null) return;

    setState(() {
      _answerChecked = true;
      if (_selectedAnswer == _quizQuestions[_currentQuestionIndex]['correct']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _quizQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _answerChecked = false;
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  void _viewVocabulary() {
    Navigator.pushNamed(
      context,
      '/vocabulary',
      arguments: widget.levelId,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_quizCompleted) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.levelTitle),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 100,
                  color: Colors.amber,
                ),
                const SizedBox(height: 24),
                Text(
                  'Quiz Completed!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Score: $_score/${_quizQuestions.length}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back to Roadmap'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = _quizQuestions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.levelTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: _viewVocabulary,
            tooltip: 'View Vocabulary',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _quizQuestions.length,
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 8),
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_quizQuestions.length}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    IconButton(
                      onPressed: _playAudio,
                      icon: const Icon(Icons.volume_up, size: 64),
                      color: Colors.blue,
                      iconSize: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentQuestion['question'] as String,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: (currentQuestion['options'] as List).length,
                itemBuilder: (context, index) {
                  final option = currentQuestion['options'][index] as String;
                  final isCorrect = option == currentQuestion['correct'];
                  final isSelected = option == _selectedAnswer;

                  Color? cardColor;
                  if (_answerChecked) {
                    if (isSelected && isCorrect) {
                      cardColor = Colors.green.shade100;
                    } else if (isSelected && !isCorrect) {
                      cardColor = Colors.red.shade100;
                    } else if (isCorrect) {
                      cardColor = Colors.green.shade100;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      color: cardColor,
                      elevation: isSelected ? 4 : 2,
                      child: InkWell(
                        onTap: _answerChecked
                            ? null
                            : () {
                                setState(() {
                                  _selectedAnswer = option;
                                });
                              },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              if (_answerChecked && isCorrect)
                                const Icon(Icons.check_circle, color: Colors.green),
                              if (_answerChecked && isSelected && !isCorrect)
                                const Icon(Icons.cancel, color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _answerChecked ? _nextQuestion : _checkAnswer,
                child: Text(_answerChecked ? 'Next Question' : 'Check Answer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}