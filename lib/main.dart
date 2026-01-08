import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:img_cls/data/notifiers.dart';
import 'package:img_cls/firebase_options.dart';
import 'package:img_cls/screens/hive_test.dart';
import 'package:img_cls/screens/splash_screen.dart';

void main() async {
  //! firebase intialization
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // //! hive intialization
  // var directory = await getApplicationDocumentsDirectory();
  // Hive.init(directory.path);
  // await Hive.initFlutter();
  // await Hive.openBox('hive-test');

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
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.black12,
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
            fontFamily: 'Inter',
            // brightness: Brightness.dark,
          ),
          home: SplashScreen(),
        );
      },
    );
  }
}

class ThemeNotifier with ChangeNotifier {
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
