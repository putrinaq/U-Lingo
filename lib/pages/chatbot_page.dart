import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final Color coralColor = const Color(0xFFFF7F50);
  final Color creamColor = const Color(0xFFFFFDD0);
  final Color goldHighlight = const Color(0xFFFFF59D); // Light Yellow for highlights

  // UPDATED: The message list now supports a 'highlighted' status
  // Format: {"sender": "user"|"bot", "text": "...", "isHighlighted": "true"|"false"}
  List<Map<String, String>> messages = [];
  bool isTyping = false;

  Future<String> sendToDeepSeek(String userMessage) async {
    const String apiKey = "sk-99e3e2ed4e1b4584a0b54bdc9daa60f5"; // Remember to secure this!
    final url = Uri.parse("https://api.deepseek.com/chat/completions");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey"
        },
        body: jsonEncode({
          "model": "deepseek-chat",
          "messages": [
            {
              "role": "system",
              "content": "You are a helpful Mandarin language tutor named U-Lingo. You help students learn Chinese (Pinyin and Hanzi). Keep answers short and encouraging."
            },
            {"role": "user", "content": userMessage}
          ],
          "stream": false
        }),
      );

      if (response.statusCode != 200) {
        return "Error: ${response.statusCode}";
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data["choices"][0]["message"]["content"];

    } catch (e) {
      return "Error: $e";
    }
  }

  void sendMessage() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add({
        "sender": "user",
        "text": text,
        "isHighlighted": "false"
      });
      isTyping = true;
    });

    _controller.clear();
    scrollToBottom();

    String reply = await sendToDeepSeek(text);

    setState(() {
      isTyping = false;
      messages.add({
        "sender": "bot",
        "text": reply.trim(),
        "isHighlighted": "false"
      });
    });

    scrollToBottom();
  }

  // New Function: Toggles the highlight color
  void toggleHighlight(int index) {
    setState(() {
      // Read current state
      bool current = messages[index]["isHighlighted"] == "true";
      // Flip it
      messages[index]["isHighlighted"] = current ? "false" : "true";
    });
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: creamColor,
      appBar: AppBar(
        title: const Text("AI Tutor", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: coralColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => setState(() => messages.clear()),
          )
        ],
      ),
      body: Column(
        children: [
          // Hint Text
          if (messages.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                "Tip: Long-press a message to save it!",
                style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
            ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (isTyping && index == messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Thinking...", style: TextStyle(color: Colors.grey)),
                  );
                }

                final msg = messages[index];
                final isUser = msg["sender"] == "user";
                final isHighlighted = msg["isHighlighted"] == "true";

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: GestureDetector(
                    // FEATURE 1: Long Press to Highlight
                    onLongPress: () => toggleHighlight(index),

                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        // Logic: If Highlighted -> Yellow. Else -> User(Coral) or Bot(White)
                        color: isHighlighted
                            ? goldHighlight
                            : (isUser ? coralColor : Colors.white),

                        borderRadius: BorderRadius.circular(16),
                        border: isHighlighted ? Border.all(color: Colors.orange, width: 2) : null,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
                        ],
                      ),
                      // FEATURE 2: Selectable Text (Allows Copy/Paste)
                      child: SelectableText(
                        msg["text"]!,
                        style: TextStyle(
                          color: isHighlighted ? Colors.black87 : (isUser ? Colors.white : Colors.black87),
                          fontSize: 16,
                          fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input Field
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => sendMessage(),
                    decoration: InputDecoration(
                      hintText: "Ask about Pinyin...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: coralColor,
                  radius: 24,
                  child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 20), onPressed: sendMessage),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}