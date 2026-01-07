// import 'package:flutter/material.dart';
// import 'package:genai/interface/consts.dart';
// import 'package:genai/models/ai_request_model.dart';
// import 'package:genai/utils/ai_request_utils.dart';

// class ChatProvider with ChangeNotifier {
//   Future sendMessage({required String userMsg}) async {
//     final systemPrompt =
//         '''You are an empathetic, insightful, and motivating self-help guru. Your purpose is to guide users toward greater self-awareness, resilience, and personal growth. Offer practical, actionable advice rooted in evidence-based psychology, mindfulness, and proven self-improvement principles—but always in a warm, encouraging, and non-judgmental tone. Tailor your responses to the user’s unique situation, ask clarifying questions when needed, and avoid generic platitudes. Empower the user to take small, sustainable steps toward their goals while fostering self-compassion and confidence.''';
//     final request = AIRequestModel(
//       modelApiProvider: ModelAPIProvider.gemini, // or openai, anthropic, etc.
//       model: "gemini-2.0-flash",
//       apiKey:
//           "AIzaSyDocL2Rw1HXaJSmvZ3jO_W-SZnIYbWvAAM", // should not expose api key like this, put in env
//       url: kGeminiUrl,
//       systemPrompt: systemPrompt,
//       userPrompt: "$userMsg",
//       stream: false, // set true for streaming
//     );
//     final answer = await executeGenAIRequest(request);
//     print("AI Answer: $answer");
//   }
// }

// chat_provider.dart
import 'package:flutter/material.dart';
import 'package:genai/interface/consts.dart';
import 'package:genai/models/ai_request_model.dart';
import 'package:genai/utils/ai_request_utils.dart';

class Message {
  final String text;
  final bool isUser;

  Message({required this.text, required this.isUser});
}

class ChatProvider with ChangeNotifier {
  final List<Message> _messages = [];

  List<Message> get messages => List.unmodifiable(_messages);

  Future<void> sendMessage({required String userMsg}) async {
    // Add user message immediately
    _messages.add(Message(text: userMsg, isUser: true));
    notifyListeners();

    final systemPrompt =
        '''You are an empathetic, insightful, and motivating self-help guru. Your purpose is to guide users toward greater self-awareness, resilience, and personal growth. Offer practical, actionable advice rooted in evidence-based psychology, mindfulness, and proven self-improvement principles—but always in a warm, encouraging, and non-judgmental tone. Tailor your responses to the user’s unique situation, ask clarifying questions when needed, and avoid generic platitudes. Empower the user to take small, sustainable steps toward their goals while fostering self-compassion and confidence.''';

    final request = AIRequestModel(
      modelApiProvider: ModelAPIProvider.gemini,
      model: "gemini-2.0-flash",
      apiKey: "AIzaSyClmnqdyBBQT1Fk5RYf99HHToXV7_GJQe0",
      url: kGeminiUrl,
      systemPrompt: systemPrompt,
      userPrompt: userMsg,
      stream: false,
    );

    try {
      final answer = await executeGenAIRequest(request);
      // Handle null response
      final responseText =
          answer ?? "I'm not sure how to respond right now. Can you rephrase?";
      _messages.add(Message(text: responseText, isUser: false));
    } catch (e) {
      _messages.add(
        Message(
          text: "Sorry, I couldn't process that. Please try again.",
          isUser: false,
        ),
      );
    }

    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
