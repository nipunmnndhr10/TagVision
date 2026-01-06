import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:img_cls/data/notifiers.dart';
import 'package:img_cls/firebase_options.dart';
import 'package:img_cls/screens/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          title: 'TagVision',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.black12),
            fontFamily: 'Inter',
            // brightness: Brightness.dark,
          ),
          home: SignupScreen(),
        );
      },
    );
  }
}
