// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:img_cls/services/chat_provider.dart';
import 'package:provider/provider.dart';
// import 'package:genai/providers/chat_provider.dart'; // adjust import path

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Self-Help Guru'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => chatProvider.clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final msg = chatProvider.messages[index];
                return Align(
                  alignment: msg.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg.text),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: "Ask for advice...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) => _sendMessage(chatProvider, value),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final msg = _textController.text.trim();
                    if (msg.isNotEmpty) {
                      _sendMessage(chatProvider, msg);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(ChatProvider provider, String message) {
    provider.sendMessage(userMsg: message);
    _textController.clear();
  }
}
