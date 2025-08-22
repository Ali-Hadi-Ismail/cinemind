import 'package:cinemind/module/onboarding/splash_screen.dart';
import 'package:cinemind/shared/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(const CineMindApp());
}

class CineMindApp extends StatelessWidget {
  const CineMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark, // Force dark mode
      debugShowCheckedModeBanner: false,
      darkTheme: CineMindTheme.darkTheme,
      home: SplashScreen(),
    );
  }
}
