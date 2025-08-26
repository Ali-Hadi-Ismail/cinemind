import 'package:cinemind/layout/home_layout.dart';
import 'package:cinemind/shared/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter(); // Initialize Hive
  await Hive.openBox('tv_cache');
  await Hive.openBox('search');
  await Hive.openBox('movies'); // Open your box
  //if I want to hide status bar and navigation bar
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
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
      home: HomeLayout(),
    );
  }
}
