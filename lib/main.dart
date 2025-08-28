import 'package:cinemind/layout/home_layout.dart';
import 'package:cinemind/module/authentication/login_screen.dart';
import 'package:cinemind/shared/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation
        .portraitDown, // optional (if you want upside-down portrait too)
  ]);
  runApp(const CineMindApp());
}

class CineMindApp extends StatefulWidget {
  const CineMindApp({super.key});

  @override
  State<CineMindApp> createState() => _CineMindAppState();
}

class _CineMindAppState extends State<CineMindApp> {
  void _checkUserLoggedIn() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is already logged in, navigate to home
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeLayout()),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark, // Force dark mode
      debugShowCheckedModeBanner: false,
      darkTheme: CineMindTheme.darkTheme,
      home: LoginScreen(),
    );
  }
}
