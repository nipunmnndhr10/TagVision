// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:img_cls/services/chat_provider.dart';
// import 'package:flutter_riverpod/all.dart'; // Not needed if using provider
import 'package:provider/provider.dart';
import 'package:img_cls/data/notifiers.dart';
import 'package:img_cls/firebase_options.dart';
import 'package:img_cls/screens/chat_screen.dart'; // Create this next
// import 'package:genai/providers/chat_provider.dart'; // adjust path if needed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return ChangeNotifierProvider(
          create: (_) => ChatProvider(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'TagVision',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.black12),
              fontFamily: 'Inter',
              // brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
            home:
                const ChatScreen(), // Replace SignupScreen with ChatScreen for testing
          ),
        );
      },
    );
  }
}
