import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
);

final localNotification = FlutterLocalNotificationsPlugin();

class LocalNotification {
  static Future<void> init() async {
    final androidFLNP = localNotification.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidFLNP?.createNotificationChannel(channel);

    const initialzationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: initialzationSettingsAndroid);

    localNotification.initialize(initializationSettings);
  }

  static void show(
    int id,
    String? title,
    String? body, {
    String? payload,
    String? icon,
  }) {
    localNotification.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: icon,
        ),
      ),
      payload: payload,
    );
  }
}
