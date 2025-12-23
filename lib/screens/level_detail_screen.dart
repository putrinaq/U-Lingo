import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pronunciation_practice_screen.dart';
import '../services/audio_player_service.dart';
import '../services/elevenlabs_service.dart';

class LevelDetailScreen extends StatefulWidget {
  final String levelDocId; // Firestore document ID
  final int levelId;
  final String levelTitle;

  const LevelDetailScreen({
    Key? key,
    required this.levelDocId,
    required this.levelId,
    required this.levelTitle,
  }) : super(key: key);

  @override
  State<LevelDetailScreen> createState() => _LevelDetailScreenState();
}

class _LevelDetailScreenState extends State<LevelDetailScreen> {
  int _currentQuizIndex = 0;
  int _score = 0;
  bool _showResult = false;
  String? _selectedAnswer;
  bool _isLoadingAudio = false;
  bool _isPlayingAudio = false;
  bool _isLoadingLevel = true;

  List<Map<String, dynamic>> _quizzes = [];
  List<Map<String, dynamic>> _pronunciations = [];

  @override
  void initState() {
    super.initState();
    _loadLevelData();
  }

  Future<void> _loadLevelData() async {
    try {
      final levelDoc = await FirebaseFirestore.instance
          .collection('levels')
          .doc(widget.levelDocId)
          .get();

      if (levelDoc.exists) {
        final data = levelDoc.data()!;
        setState(() {
          _quizzes = List<Map<String, dynamic>>.from(data['quizzes'] ?? []);
          _pronunciations = List<Map<String, dynamic>>.from(
            data['pronunciations'] ?? [],
          );
          _isLoadingLevel = false;
        });
      } else {
        setState(() => _isLoadingLevel = false);
      }
    } catch (e) {
      print('Error loading level data: $e');
      setState(() => _isLoadingLevel = false);
    }
  }

  Map<String, dynamic> get _currentQuiz {
    if (_quizzes.isEmpty) return {};
    return _quizzes[_currentQuizIndex];
  }

  Future<void> _playAudio() async {
    if (_isLoadingAudio || _isPlayingAudio || _quizzes.isEmpty) return;

    setState(() {
      _isLoadingAudio = true;
      _isPlayingAudio = true;
    });

    try {
      final audioText = _currentQuiz['audio'] as String;
      final audioBytes = await ElevenLabsService.textToSpeech(audioText);

      if (audioBytes != null) {
        await AudioPlayerService.playAudio(audioBytes);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load audio'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAudio = false;
          _isPlayingAudio = false;
        });
      }
    }
  }

  void _selectAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) return;

    final isCorrect = _selectedAnswer == _currentQuiz['correct'];
    if (isCorrect) {
      _score++;
    }

    if (_currentQuizIndex < _quizzes.length - 1) {
      setState(() {
        _currentQuizIndex++;
        _selectedAnswer = null;
      });
    } else {
      _completeLevel();
    }
  }

  Future<void> _completeLevel() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    final userData = userDoc.data()!;
    final completedLevels = List<int>.from(userData['completedLevels'] ?? []);
    final currentLevel = userData['currentLevel'] ?? 1;

    if (!completedLevels.contains(widget.levelId)) {
      completedLevels.add(widget.levelId);

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'completedLevels': completedLevels,
        'currentLevel': widget.levelId == currentLevel ? currentLevel + 1 : currentLevel,
      });
    }

    setState(() {
      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLevel) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.levelTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_quizzes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.levelTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No quizzes available',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please contact the admin to add quizzes for this level',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_showResult) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Results'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _score >= _quizzes.length * 0.7
                      ? Icons.celebration
                      : Icons.sentiment_satisfied,
                  size: 100,
                  color: _score >= _quizzes.length * 0.7
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(height: 24),
                Text(
                  _score >= _quizzes.length * 0.7
                      ? 'Great Job!'
                      : 'Good Effort!',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'You scored $_score out of ${_quizzes.length}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.levelTitle),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentQuizIndex + 1}/${_quizzes.length}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentQuizIndex + 1) / _quizzes.length,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    child: InkWell(
                      onTap: _playAudio,
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            _isLoadingAudio
                                ? const SizedBox(
                              width: 64,
                              height: 64,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                              ),
                            )
                                : Icon(
                              _isPlayingAudio
                                  ? Icons.volume_up
                                  : Icons.play_circle_outline,
                              size: 64,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _currentQuiz['audio'] ?? '',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isLoadingAudio
                                  ? 'Loading audio...'
                                  : 'Tap to play audio',
                              style: TextStyle(
                                color: _isLoadingAudio
                                    ? Colors.orange
                                    : Colors.grey,
                                fontWeight: _isLoadingAudio
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    _currentQuiz['question'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(
                    (_currentQuiz['options'] as List?)?.length ?? 0,
                        (index) {
                      final options = _currentQuiz['options'] as List;
                      final option = options[index];
                      final isSelected = _selectedAnswer == option;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _selectAnswer(option),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey,
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check,
                                      size: 20, color: Colors.blue)
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  if (_pronunciations.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PronunciationPracticeScreen(
                              levelDocId: widget.levelDocId,
                              levelId: widget.levelId,
                              levelTitle: widget.levelTitle,
                              pronunciations: _pronunciations,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.mic),
                      label: const Text('Pronunciation Practice'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.purple,
                        side: const BorderSide(color: Colors.purple, width: 2),
                      ),
                    ),
                  if (_pronunciations.isNotEmpty) const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _selectedAnswer == null ? null : _submitAnswer,
                      child: Text(
                        _currentQuizIndex < _quizzes.length - 1
                            ? 'Next Question'
                            : 'Finish Quiz',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}