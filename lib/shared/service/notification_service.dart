import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:app_settings/app_settings.dart';
import 'package:cinemind/shared/constant/phrase.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize notifications
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // default small icon

    const InitializationSettings initSettings =
        InitializationSettings(android: androidInitSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint("Notification tapped: ${response.payload}");
    });
  }

  /// Show a single notification immediately
  static Future<void> showBasicNotification() async {
    final androidDetails = AndroidNotificationDetails(
      'basic_channel_v3',
      'Basic Notifications',
      channelDescription: 'Immediate notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('cinemind_notification_1'),
      channelShowBadge: true,
      // icon removed, will use default system icon
    );

    final platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'CineMind 🎬',
      Phrase().getRandomMoviePhrase(),
      platformDetails,
      payload: 'movie_123',
    );
  }

  /// Schedule notifications every 3 hours for the next 24 hours
  static Future<void> schedule3HourNotifications() async {
    final androidDetails = AndroidNotificationDetails(
      'repeating_channel_v2',
      '3-Hour Notifications',
      channelDescription: 'CineMind notifications every 3 hours',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('cinemind_notification_1'),
      channelShowBadge: true,
    );

    final platformDetails = NotificationDetails(android: androidDetails);

    // Cancel any old scheduled notifications
    await flutterLocalNotificationsPlugin.cancelAll();

    // Schedule notifications for the next 24 hours
    for (int i = 0; i < 8; i++) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        100 + i, // unique ID
        'CineMind 🎬',
        Phrase().getRandomMoviePhrase(),
        tz.TZDateTime.now(tz.local).add(Duration(hours: 3 * i)),
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  /// Open system notification settings
  static void openNotificationSettings() {
    AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  /// Check and request notification permission
  static Future<void> checkAndRequestNotificationPermission(
      BuildContext context) async {
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final granted = await androidPlugin?.areNotificationsEnabled() ?? false;

    if (!granted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Enable Notifications"),
          content: const Text(
              "CineMind needs notification permission to show notifications every 3 hours."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                openNotificationSettings();
              },
              child: const Text("Open Settings"),
            ),
          ],
        ),
      );
    }
  }
}
