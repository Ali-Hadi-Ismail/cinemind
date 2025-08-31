import 'package:cinemind/layout/home_layout.dart';
import 'package:cinemind/module/authentication/login_screen.dart';
import 'package:cinemind/shared/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

import 'module/impulse/cinemind_screen.dart';
import 'shared/service/notification_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// WorkManager callback
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await NotificationService.schedule3HourNotifications();
    return Future.value(true);
  });
}

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
  await NotificationService.initialize();
  runApp(const CineMindApp());
}

class CineMindApp extends StatelessWidget {
  const CineMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      darkTheme: CineMindTheme.darkTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Loading state while Firebase checks user
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // User is logged in
          if (snapshot.hasData) {
            return HomeLayout();
          }

          // User not logged in
          return const LoginScreen();
        },
      ),
    );
  }
}
