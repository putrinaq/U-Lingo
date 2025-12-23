import 'package:flutter/material.dart';
import 'package:ulingo/services/audio_player_service.dart';
import 'package:ulingo/services/elevenlabs_service.dart';

class PronunciationPracticeScreen extends StatefulWidget {
  final String levelDocId;
  final int levelId;
  final String levelTitle;
  final List<Map<String, dynamic>> pronunciations;

  const PronunciationPracticeScreen({
    Key? key,
    required this.levelDocId,
    required this.levelId,
    required this.levelTitle,
    required this.pronunciations,
  }) : super(key: key);

  @override
  State<PronunciationPracticeScreen> createState() =>
      _PronunciationPracticeScreenState();
}

class _PronunciationPracticeScreenState
    extends State<PronunciationPracticeScreen> {
  int _currentWordIndex = 0;
  bool _isRecording = false;
  bool _hasRecorded = false;
  bool _showFeedback = false;
  double _pronunciationScore = 0.0;
  String _feedbackText = '';
  bool _isPlayingModel = false;
  bool _isLoadingAudio = false;

  Map<String, dynamic> get _currentWord {
    if (widget.pronunciations.isEmpty) return {};
    return widget.pronunciations[_currentWordIndex];
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _showFeedback = false;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _stopRecording();
      }
    });
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
      _hasRecorded = true;
    });
    _analyzePronunciation();
  }

  void _analyzePronunciation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        final score = 60 + (40 * (0.5 + (DateTime.now().millisecond % 500) / 1000));

        String feedback;
        if (score >= 90) {
          feedback = 'Excellent! Your pronunciation is very accurate.';
        } else if (score >= 75) {
          feedback = 'Good job! Pay attention to the tone.';
        } else if (score >= 60) {
          feedback = 'Keep practicing! Focus on the rising tone.';
        } else {
          feedback = 'Try again. Listen carefully to the model.';
        }

        setState(() {
          _pronunciationScore = score;
          _feedbackText = feedback;
          _showFeedback = true;
        });
      }
    });
  }

  Future<void> _playModelPronunciation({bool slow = false}) async {
    if (_isLoadingAudio || _isPlayingModel) return;

    setState(() {
      _isPlayingModel = true;
      _isLoadingAudio = true;
    });

    try {
      final word = _currentWord['word'] as String;
      final audioBytes = await ElevenLabsService.textToSpeech(word);

      if (audioBytes != null) {
        await AudioPlayerService.playAudio(audioBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                slow
                    ? 'Playing model pronunciation (slow)'
                    : 'Playing model pronunciation',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        }
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
          _isPlayingModel = false;
          _isLoadingAudio = false;
        });
      }
    }
  }

  void _nextWord() {
    if (_currentWordIndex < widget.pronunciations.length - 1) {
      setState(() {
        _currentWordIndex++;
        _hasRecorded = false;
        _showFeedback = false;
        _pronunciationScore = 0.0;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _previousWord() {
    if (_currentWordIndex > 0) {
      setState(() {
        _currentWordIndex--;
        _hasRecorded = false;
        _showFeedback = false;
        _pronunciationScore = 0.0;
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Practice Complete!'),
        content: const Text(
          'Great job completing the pronunciation practice. Keep practicing to improve your accent!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Finish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentWordIndex = 0;
                _hasRecorded = false;
                _showFeedback = false;
              });
            },
            child: const Text('Practice Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pronunciations.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pronunciation Practice'),
        ),
        body: const Center(
          child: Text(
            'No pronunciation exercises available for this level',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Pronunciation Practice - ${widget.levelTitle}'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentWordIndex + 1}/${widget.pronunciations.length}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentWordIndex + 1) / widget.pronunciations.length,
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 4,
                    color: Colors.blue[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Text(
                            _currentWord['word'] ?? '',
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _currentWord['pinyin'] ?? '',
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _currentWord['translation'] ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber, width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.amber),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _currentWord['tips'] ?? '',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Listen to Model Pronunciation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (_isPlayingModel || _isLoadingAudio)
                              ? null
                              : () => _playModelPronunciation(),
                          icon: _isLoadingAudio
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Icon(_isPlayingModel
                              ? Icons.volume_up
                              : Icons.play_arrow),
                          label: const Text('Normal Speed'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: (_isPlayingModel || _isLoadingAudio)
                              ? null
                              : () => _playModelPronunciation(slow: true),
                          icon: const Icon(Icons.slow_motion_video),
                          label: const Text('Slow'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Record Your Pronunciation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: GestureDetector(
                      onTap: _isRecording ? null : _startRecording,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _isRecording ? 100 : 120,
                        height: _isRecording ? 100 : 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording ? Colors.red : Colors.blue,
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecording ? Colors.red : Colors.blue)
                                  .withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: _isRecording ? 10 : 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _isRecording
                          ? 'Recording...'
                          : _hasRecorded
                          ? 'Tap to record again'
                          : 'Tap to start recording',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  if (_showFeedback) ...[
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _pronunciationScore >= 75
                              ? [Colors.green[400]!, Colors.green[600]!]
                              : _pronunciationScore >= 60
                              ? [Colors.orange[400]!, Colors.orange[600]!]
                              : [Colors.red[400]!, Colors.red[600]!],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _pronunciationScore >= 75
                                    ? Icons.star
                                    : _pronunciationScore >= 60
                                    ? Icons.thumb_up
                                    : Icons.refresh,
                                size: 40,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${_pronunciationScore.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _feedbackText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      if (_currentWordIndex > 0)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _previousWord,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      if (_currentWordIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _nextWord,
                          icon: Icon(_currentWordIndex <
                              widget.pronunciations.length - 1
                              ? Icons.arrow_forward
                              : Icons.check),
                          label: Text(_currentWordIndex <
                              widget.pronunciations.length - 1
                              ? 'Next Word'
                              : 'Complete'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
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