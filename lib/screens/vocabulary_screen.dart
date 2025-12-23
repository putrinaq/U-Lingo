import 'package:flutter/material.dart';
import 'package:ulingo/services/audio_player_service.dart';
import 'package:ulingo/services/elevenlabs_service.dart';

class VocabularyScreen extends StatefulWidget {
  final int levelId; // Not used in new design but kept for compatibility

  const VocabularyScreen({Key? key, required this.levelId}) : super(key: key);

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _expandedWords = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 50 English words (A-Z) with Mandarin translations and example sentences
  final List<Map<String, String>> _vocabularyList = [
    {'english': 'Afternoon', 'mandarin': '下午', 'pinyin': 'xià wǔ', 'sentence': '下午我要去学校', 'sentencePinyin': 'xià wǔ wǒ yào qù xué xiào', 'sentenceTranslation': 'I will go to school in the afternoon'},
    {'english': 'Again', 'mandarin': '再', 'pinyin': 'zài', 'sentence': '请再说一次', 'sentencePinyin': 'qǐng zài shuō yī cì', 'sentenceTranslation': 'Please say it again'},
    {'english': 'Apple', 'mandarin': '苹果', 'pinyin': 'píng guǒ', 'sentence': '我喜欢吃苹果', 'sentencePinyin': 'wǒ xǐ huān chī píng guǒ', 'sentenceTranslation': 'I like to eat apples'},
    {'english': 'Beautiful', 'mandarin': '美丽', 'pinyin': 'měi lì', 'sentence': '这朵花很美丽', 'sentencePinyin': 'zhè duǒ huā hěn měi lì', 'sentenceTranslation': 'This flower is very beautiful'},
    {'english': 'Book', 'mandarin': '书', 'pinyin': 'shū', 'sentence': '我在看书', 'sentencePinyin': 'wǒ zài kàn shū', 'sentenceTranslation': 'I am reading a book'},
    {'english': 'Brother', 'mandarin': '兄弟', 'pinyin': 'xiōng dì', 'sentence': '他是我的兄弟', 'sentencePinyin': 'tā shì wǒ de xiōng dì', 'sentenceTranslation': 'He is my brother'},
    {'english': 'Car', 'mandarin': '车', 'pinyin': 'chē', 'sentence': '我爸爸有一辆车', 'sentencePinyin': 'wǒ bà ba yǒu yī liàng chē', 'sentenceTranslation': 'My father has a car'},
    {'english': 'Cat', 'mandarin': '猫', 'pinyin': 'māo', 'sentence': '我家有一只猫', 'sentencePinyin': 'wǒ jiā yǒu yī zhī māo', 'sentenceTranslation': 'My family has a cat'},
    {'english': 'Chair', 'mandarin': '椅子', 'pinyin': 'yǐ zi', 'sentence': '请坐在椅子上', 'sentencePinyin': 'qǐng zuò zài yǐ zi shàng', 'sentenceTranslation': 'Please sit on the chair'},
    {'english': 'Child', 'mandarin': '孩子', 'pinyin': 'hái zi', 'sentence': '这个孩子很聪明', 'sentencePinyin': 'zhè gè hái zi hěn cōng míng', 'sentenceTranslation': 'This child is very smart'},
    {'english': 'City', 'mandarin': '城市', 'pinyin': 'chéng shì', 'sentence': '北京是一个大城市', 'sentencePinyin': 'běi jīng shì yī gè dà chéng shì', 'sentenceTranslation': 'Beijing is a big city'},
    {'english': 'Cold', 'mandarin': '冷', 'pinyin': 'lěng', 'sentence': '今天很冷', 'sentencePinyin': 'jīn tiān hěn lěng', 'sentenceTranslation': 'Today is very cold'},
    {'english': 'Country', 'mandarin': '国家', 'pinyin': 'guó jiā', 'sentence': '中国是一个大国家', 'sentencePinyin': 'zhōng guó shì yī gè dà guó jiā', 'sentenceTranslation': 'China is a big country'},
    {'english': 'Day', 'mandarin': '天', 'pinyin': 'tiān', 'sentence': '今天是星期一', 'sentencePinyin': 'jīn tiān shì xīng qī yī', 'sentenceTranslation': 'Today is Monday'},
    {'english': 'Dog', 'mandarin': '狗', 'pinyin': 'gǒu', 'sentence': '我的狗很可爱', 'sentencePinyin': 'wǒ de gǒu hěn kě ài', 'sentenceTranslation': 'My dog is very cute'},
    {'english': 'Door', 'mandarin': '门', 'pinyin': 'mén', 'sentence': '请关门', 'sentencePinyin': 'qǐng guān mén', 'sentenceTranslation': 'Please close the door'},
    {'english': 'Eat', 'mandarin': '吃', 'pinyin': 'chī', 'sentence': '我想吃饭', 'sentencePinyin': 'wǒ xiǎng chī fàn', 'sentenceTranslation': 'I want to eat'},
    {'english': 'Evening', 'mandarin': '晚上', 'pinyin': 'wǎn shang', 'sentence': '晚上见', 'sentencePinyin': 'wǎn shang jiàn', 'sentenceTranslation': 'See you in the evening'},
    {'english': 'Family', 'mandarin': '家庭', 'pinyin': 'jiā tíng', 'sentence': '我爱我的家庭', 'sentencePinyin': 'wǒ ài wǒ de jiā tíng', 'sentenceTranslation': 'I love my family'},
    {'english': 'Father', 'mandarin': '父亲', 'pinyin': 'fù qīn', 'sentence': '我的父亲是老师', 'sentencePinyin': 'wǒ de fù qīn shì lǎo shī', 'sentenceTranslation': 'My father is a teacher'},
    {'english': 'Fish', 'mandarin': '鱼', 'pinyin': 'yú', 'sentence': '我喜欢吃鱼', 'sentencePinyin': 'wǒ xǐ huān chī yú', 'sentenceTranslation': 'I like to eat fish'},
    {'english': 'Food', 'mandarin': '食物', 'pinyin': 'shí wù', 'sentence': '这个食物很好吃', 'sentencePinyin': 'zhè gè shí wù hěn hǎo chī', 'sentenceTranslation': 'This food is delicious'},
    {'english': 'Friend', 'mandarin': '朋友', 'pinyin': 'péng you', 'sentence': '他是我的好朋友', 'sentencePinyin': 'tā shì wǒ de hǎo péng you', 'sentenceTranslation': 'He is my good friend'},
    {'english': 'Good', 'mandarin': '好', 'pinyin': 'hǎo', 'sentence': '这个很好', 'sentencePinyin': 'zhè gè hěn hǎo', 'sentenceTranslation': 'This is very good'},
    {'english': 'Goodbye', 'mandarin': '再见', 'pinyin': 'zài jiàn', 'sentence': '明天见，再见', 'sentencePinyin': 'míng tiān jiàn, zài jiàn', 'sentenceTranslation': 'See you tomorrow, goodbye'},
    {'english': 'Happy', 'mandarin': '快乐', 'pinyin': 'kuài lè', 'sentence': '祝你生日快乐', 'sentencePinyin': 'zhù nǐ shēng rì kuài lè', 'sentenceTranslation': 'Happy birthday to you'},
    {'english': 'Hello', 'mandarin': '你好', 'pinyin': 'nǐ hǎo', 'sentence': '你好，很高兴见到你', 'sentencePinyin': 'nǐ hǎo, hěn gāo xìng jiàn dào nǐ', 'sentenceTranslation': 'Hello, nice to meet you'},
    {'english': 'Home', 'mandarin': '家', 'pinyin': 'jiā', 'sentence': '我要回家', 'sentencePinyin': 'wǒ yào huí jiā', 'sentenceTranslation': 'I want to go home'},
    {'english': 'Hot', 'mandarin': '热', 'pinyin': 'rè', 'sentence': '今天很热', 'sentencePinyin': 'jīn tiān hěn rè', 'sentenceTranslation': 'Today is very hot'},
    {'english': 'House', 'mandarin': '房子', 'pinyin': 'fáng zi', 'sentence': '这是我的房子', 'sentencePinyin': 'zhè shì wǒ de fáng zi', 'sentenceTranslation': 'This is my house'},
    {'english': 'Important', 'mandarin': '重要', 'pinyin': 'zhòng yào', 'sentence': '这很重要', 'sentencePinyin': 'zhè hěn zhòng yào', 'sentenceTranslation': 'This is very important'},
    {'english': 'Job', 'mandarin': '工作', 'pinyin': 'gōng zuò', 'sentence': '我在找工作', 'sentencePinyin': 'wǒ zài zhǎo gōng zuò', 'sentenceTranslation': 'I am looking for a job'},
    {'english': 'Kitchen', 'mandarin': '厨房', 'pinyin': 'chú fáng', 'sentence': '妈妈在厨房做饭', 'sentencePinyin': 'mā ma zài chú fáng zuò fàn', 'sentenceTranslation': 'Mom is cooking in the kitchen'},
    {'english': 'Language', 'mandarin': '语言', 'pinyin': 'yǔ yán', 'sentence': '我在学习中文语言', 'sentencePinyin': 'wǒ zài xué xí zhōng wén yǔ yán', 'sentenceTranslation': 'I am learning Chinese language'},
    {'english': 'Love', 'mandarin': '爱', 'pinyin': 'ài', 'sentence': '我爱我的家人', 'sentencePinyin': 'wǒ ài wǒ de jiā rén', 'sentenceTranslation': 'I love my family'},
    {'english': 'Money', 'mandarin': '钱', 'pinyin': 'qián', 'sentence': '我没有钱', 'sentencePinyin': 'wǒ méi yǒu qián', 'sentenceTranslation': 'I have no money'},
    {'english': 'Morning', 'mandarin': '早上', 'pinyin': 'zǎo shang', 'sentence': '早上好', 'sentencePinyin': 'zǎo shang hǎo', 'sentenceTranslation': 'Good morning'},
    {'english': 'Mother', 'mandarin': '母亲', 'pinyin': 'mǔ qīn', 'sentence': '我的母亲很温柔', 'sentencePinyin': 'wǒ de mǔ qīn hěn wēn róu', 'sentenceTranslation': 'My mother is very gentle'},
    {'english': 'Name', 'mandarin': '名字', 'pinyin': 'míng zi', 'sentence': '你叫什么名字', 'sentencePinyin': 'nǐ jiào shén me míng zi', 'sentenceTranslation': 'What is your name'},
    {'english': 'Night', 'mandarin': '夜晚', 'pinyin': 'yè wǎn', 'sentence': '夜晚很安静', 'sentencePinyin': 'yè wǎn hěn ān jìng', 'sentenceTranslation': 'The night is very quiet'},
    {'english': 'People', 'mandarin': '人们', 'pinyin': 'rén men', 'sentence': '人们很友好', 'sentencePinyin': 'rén men hěn yǒu hǎo', 'sentenceTranslation': 'People are very friendly'},
    {'english': 'Question', 'mandarin': '问题', 'pinyin': 'wèn tí', 'sentence': '我有一个问题', 'sentencePinyin': 'wǒ yǒu yī gè wèn tí', 'sentenceTranslation': 'I have a question'},
    {'english': 'Rain', 'mandarin': '雨', 'pinyin': 'yǔ', 'sentence': '今天下雨了', 'sentencePinyin': 'jīn tiān xià yǔ le', 'sentenceTranslation': 'It rained today'},
    {'english': 'School', 'mandarin': '学校', 'pinyin': 'xué xiào', 'sentence': '我每天去学校', 'sentencePinyin': 'wǒ měi tiān qù xué xiào', 'sentenceTranslation': 'I go to school every day'},
    {'english': 'Sister', 'mandarin': '姐妹', 'pinyin': 'jiě mèi', 'sentence': '我有两个姐妹', 'sentencePinyin': 'wǒ yǒu liǎng gè jiě mèi', 'sentenceTranslation': 'I have two sisters'},
    {'english': 'Student', 'mandarin': '学生', 'pinyin': 'xué sheng', 'sentence': '我是一个学生', 'sentencePinyin': 'wǒ shì yī gè xué sheng', 'sentenceTranslation': 'I am a student'},
    {'english': 'Teacher', 'mandarin': '老师', 'pinyin': 'lǎo shī', 'sentence': '我的老师很好', 'sentencePinyin': 'wǒ de lǎo shī hěn hǎo', 'sentenceTranslation': 'My teacher is very good'},
    {'english': 'Time', 'mandarin': '时间', 'pinyin': 'shí jiān', 'sentence': '现在几点了', 'sentencePinyin': 'xiàn zài jǐ diǎn le', 'sentenceTranslation': 'What time is it now'},
    {'english': 'Water', 'mandarin': '水', 'pinyin': 'shuǐ', 'sentence': '我想喝水', 'sentencePinyin': 'wǒ xiǎng hē shuǐ', 'sentenceTranslation': 'I want to drink water'},
    {'english': 'Year', 'mandarin': '年', 'pinyin': 'nián', 'sentence': '今年是2024年', 'sentencePinyin': 'jīn nián shì èr líng èr sì nián', 'sentenceTranslation': 'This year is 2024'},
  ];

  List<Map<String, String>> _getFilteredVocabulary() {
    if (_searchQuery.isEmpty) {
      return _vocabularyList;
    }
    return _vocabularyList
        .where((item) =>
        item['english']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredVocabulary = _getFilteredVocabulary();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vocabulary'),
        automaticallyImplyLeading: widget.levelId != 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for English words...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Word count indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${filteredVocabulary.length} word${filteredVocabulary.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Vocabulary list
          Expanded(
            child: filteredVocabulary.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No words found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different search term',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredVocabulary.length,
              itemBuilder: (context, index) {
                final item = filteredVocabulary[index];
                final isExpanded =
                _expandedWords.contains(item['english']);

                return _VocabularyItem(
                  english: item['english']!,
                  mandarin: item['mandarin']!,
                  pinyin: item['pinyin']!,
                  sentence: item['sentence']!,
                  sentencePinyin: item['sentencePinyin']!,
                  sentenceTranslation: item['sentenceTranslation']!,
                  isExpanded: isExpanded,
                  onTap: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedWords.remove(item['english']);
                      } else {
                        _expandedWords.add(item['english']!);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VocabularyItem extends StatefulWidget {
  final String english;
  final String mandarin;
  final String pinyin;
  final String sentence;
  final String sentencePinyin;
  final String sentenceTranslation;
  final bool isExpanded;
  final VoidCallback onTap;

  const _VocabularyItem({
    Key? key,
    required this.english,
    required this.mandarin,
    required this.pinyin,
    required this.sentence,
    required this.sentencePinyin,
    required this.sentenceTranslation,
    required this.isExpanded,
    required this.onTap,
  }) : super(key: key);

  @override
  State<_VocabularyItem> createState() => _VocabularyItemState();
}

class _VocabularyItemState extends State<_VocabularyItem> {
  bool _isLoadingAudio = false;
  bool _isLoadingSentenceAudio = false;

  Future<void> _playAudio() async {
    if (_isLoadingAudio) return;

    setState(() => _isLoadingAudio = true);

    try {
      final audioBytes = await ElevenLabsService.textToSpeech(widget.mandarin);

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
        setState(() => _isLoadingAudio = false);
      }
    }
  }

  Future<void> _playSentenceAudio() async {
    if (_isLoadingSentenceAudio) return;

    setState(() => _isLoadingSentenceAudio = true);

    try {
      final audioBytes = await ElevenLabsService.textToSpeech(widget.sentence);

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
      print('Error playing sentence audio: $e');
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
        setState(() => _isLoadingSentenceAudio = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: widget.isExpanded ? Colors.blue : Colors.grey[200]!,
          width: widget.isExpanded ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.english,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Icon(
                    widget.isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              if (widget.isExpanded) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mandarin Translation',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.mandarin,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.pinyin,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: _isLoadingAudio
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue),
                          ),
                        )
                            : const Icon(Icons.volume_up),
                        iconSize: 28,
                        color: Colors.blue,
                        onPressed: _isLoadingAudio ? null : _playAudio,
                        tooltip: 'Play pronunciation',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Example Sentence Section
                const Text(
                  'Example Sentence',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _isLoadingSentenceAudio ? null : _playSentenceAudio,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.sentence,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.sentencePinyin,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.sentenceTranslation,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            shape: BoxShape.circle,
                          ),
                          child: _isLoadingSentenceAudio
                              ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.green),
                              ),
                            ),
                          )
                              : IconButton(
                            icon: const Icon(Icons.volume_up),
                            iconSize: 24,
                            color: Colors.green[700],
                            onPressed: _playSentenceAudio,
                            tooltip: 'Play sentence',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}