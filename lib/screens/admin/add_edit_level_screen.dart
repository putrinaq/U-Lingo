import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEditLevelScreen extends StatefulWidget {
  final String? levelId;
  final Map<String, dynamic>? levelData;

  const AddEditLevelScreen({
    Key? key,
    this.levelId,
    this.levelData,
  }) : super(key: key);

  @override
  State<AddEditLevelScreen> createState() => _AddEditLevelScreenState();
}

class _AddEditLevelScreenState extends State<AddEditLevelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _levelIdController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Map<String, dynamic>> _quizzes = [];
  List<Map<String, dynamic>> _pronunciations = [];

  bool _isLoading = false;
  bool get _isEditing => widget.levelId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing && widget.levelData != null) {
      _levelIdController.text = widget.levelData!['levelId'].toString();
      _titleController.text = widget.levelData!['title'] ?? '';
      _descriptionController.text = widget.levelData!['description'] ?? '';
      _quizzes = List<Map<String, dynamic>>.from(
        widget.levelData!['quizzes'] ?? [],
      );
      _pronunciations = List<Map<String, dynamic>>.from(
        widget.levelData!['pronunciations'] ?? [],
      );
    }
  }

  @override
  void dispose() {
    _levelIdController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveLevel() async {
    if (!_formKey.currentState!.validate()) return;

    if (_quizzes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one quiz'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final levelData = {
        'levelId': int.parse(_levelIdController.text),
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'quizzes': _quizzes,
        'pronunciations': _pronunciations,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_isEditing) {
        await FirebaseFirestore.instance
            .collection('levels')
            .doc(widget.levelId)
            .update(levelData);
      } else {
        levelData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('levels').add(levelData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Level updated successfully'
                  : 'Level created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addQuiz() {
    showDialog(
      context: context,
      builder: (context) => _QuizDialog(
        onSave: (quiz) {
          setState(() {
            _quizzes.add(quiz);
          });
        },
      ),
    );
  }

  void _editQuiz(int index) {
    showDialog(
      context: context,
      builder: (context) => _QuizDialog(
        quiz: _quizzes[index],
        onSave: (quiz) {
          setState(() {
            _quizzes[index] = quiz;
          });
        },
      ),
    );
  }

  void _deleteQuiz(int index) {
    setState(() {
      _quizzes.removeAt(index);
    });
  }

  void _addPronunciation() {
    showDialog(
      context: context,
      builder: (context) => _PronunciationDialog(
        onSave: (pronunciation) {
          setState(() {
            _pronunciations.add(pronunciation);
          });
        },
      ),
    );
  }

  void _editPronunciation(int index) {
    showDialog(
      context: context,
      builder: (context) => _PronunciationDialog(
        pronunciation: _pronunciations[index],
        onSave: (pronunciation) {
          setState(() {
            _pronunciations[index] = pronunciation;
          });
        },
      ),
    );
  }

  void _deletePronunciation(int index) {
    setState(() {
      _pronunciations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Level' : 'Add New Level'),
        backgroundColor: Colors.orange,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveLevel,
              tooltip: 'Save Level',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _levelIdController,
                      decoration: const InputDecoration(
                        labelText: 'Level ID *',
                        hintText: 'e.g., 1, 2, 3...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Level ID is required';
                        }
                        if (int.tryParse(value!) == null) {
                          return 'Must be a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Level Title *',
                        hintText: 'e.g., Basic Greetings',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        hintText: 'e.g., Learn common greetings',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Description is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quizzes Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Quizzes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addQuiz,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Quiz'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_quizzes.length} quiz(es) added',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (_quizzes.isEmpty) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.quiz_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No quizzes added yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      ..._quizzes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final quiz = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: Colors.blue[50],
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              quiz['audio'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(quiz['question'] ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _editQuiz(index),
                                  color: Colors.blue,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () => _deleteQuiz(index),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pronunciation Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pronunciation Practice',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addPronunciation,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Word'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_pronunciations.length} word(s) added',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (_pronunciations.isEmpty) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.mic_none,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No pronunciation words added yet',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 16),
                      ..._pronunciations.asMap().entries.map((entry) {
                        final index = entry.key;
                        final pron = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: Colors.purple[50],
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.purple,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  pron['word'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  pron['pinyin'] ?? '',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(pron['translation'] ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _editPronunciation(index),
                                  color: Colors.purple,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () => _deletePronunciation(index),
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            ElevatedButton.icon(
              onPressed: _saveLevel,
              icon: const Icon(Icons.save),
              label: Text(_isEditing ? 'Update Level' : 'Create Level'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// Quiz Dialog
class _QuizDialog extends StatefulWidget {
  final Map<String, dynamic>? quiz;
  final Function(Map<String, dynamic>) onSave;

  const _QuizDialog({
    Key? key,
    this.quiz,
    required this.onSave,
  }) : super(key: key);

  @override
  State<_QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<_QuizDialog> {
  final _formKey = GlobalKey<FormState>();
  final _audioController = TextEditingController();
  final _questionController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();
  final _correctController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.quiz != null) {
      _audioController.text = widget.quiz!['audio'] ?? '';
      _questionController.text = widget.quiz!['question'] ?? '';
      final options = List<String>.from(widget.quiz!['options'] ?? []);
      if (options.length >= 4) {
        _option1Controller.text = options[0];
        _option2Controller.text = options[1];
        _option3Controller.text = options[2];
        _option4Controller.text = options[3];
      }
      _correctController.text = widget.quiz!['correct'] ?? '';
    }
  }

  @override
  void dispose() {
    _audioController.dispose();
    _questionController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    _correctController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final quiz = {
      'audio': _audioController.text.trim(),
      'question': _questionController.text.trim(),
      'options': [
        _option1Controller.text.trim(),
        _option2Controller.text.trim(),
        _option3Controller.text.trim(),
        _option4Controller.text.trim(),
      ],
      'correct': _correctController.text.trim(),
    };

    widget.onSave(quiz);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.quiz == null ? 'Add Quiz' : 'Edit Quiz'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _audioController,
                decoration: const InputDecoration(
                  labelText: 'Audio Text (Chinese) *',
                  hintText: 'e.g., 你好',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question *',
                  hintText: 'e.g., What does this mean?',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _option1Controller,
                decoration: const InputDecoration(
                  labelText: 'Option 1 *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _option2Controller,
                decoration: const InputDecoration(
                  labelText: 'Option 2 *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _option3Controller,
                decoration: const InputDecoration(
                  labelText: 'Option 3 *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _option4Controller,
                decoration: const InputDecoration(
                  labelText: 'Option 4 *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _correctController,
                decoration: const InputDecoration(
                  labelText: 'Correct Answer *',
                  hintText: 'Must match one of the options',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Pronunciation Dialog
class _PronunciationDialog extends StatefulWidget {
  final Map<String, dynamic>? pronunciation;
  final Function(Map<String, dynamic>) onSave;

  const _PronunciationDialog({
    Key? key,
    this.pronunciation,
    required this.onSave,
  }) : super(key: key);

  @override
  State<_PronunciationDialog> createState() => _PronunciationDialogState();
}

class _PronunciationDialogState extends State<_PronunciationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _pinyinController = TextEditingController();
  final _translationController = TextEditingController();
  final _tipsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.pronunciation != null) {
      _wordController.text = widget.pronunciation!['word'] ?? '';
      _pinyinController.text = widget.pronunciation!['pinyin'] ?? '';
      _translationController.text = widget.pronunciation!['translation'] ?? '';
      _tipsController.text = widget.pronunciation!['tips'] ?? '';
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _pinyinController.dispose();
    _translationController.dispose();
    _tipsController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final pronunciation = {
      'word': _wordController.text.trim(),
      'pinyin': _pinyinController.text.trim(),
      'translation': _translationController.text.trim(),
      'tips': _tipsController.text.trim(),
    };

    widget.onSave(pronunciation);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.pronunciation == null
            ? 'Add Pronunciation Word'
            : 'Edit Pronunciation Word',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _wordController,
                decoration: const InputDecoration(
                  labelText: 'Chinese Word *',
                  hintText: 'e.g., 你好',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 20),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pinyinController,
                decoration: const InputDecoration(
                  labelText: 'Pinyin *',
                  hintText: 'e.g., nǐ hǎo',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _translationController,
                decoration: const InputDecoration(
                  labelText: 'English Translation *',
                  hintText: 'e.g., Hello',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tipsController,
                decoration: const InputDecoration(
                  labelText: 'Pronunciation Tips *',
                  hintText: 'e.g., The tone goes down then up',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          child: const Text('Save'),
        ),
      ],
    );
  }
}