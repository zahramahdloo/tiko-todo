import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    final timeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone.identifier));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required int minutes,
  }) async {
    if (kDebugMode) {
      debugPrint(
        'REMINDER scheduled => ${DateTime.now().add(Duration(minutes: minutes))}',
      );
    }

    await _plugin.zonedSchedule(
      id: id,
      title: 'یادآوری کار',
      body: title,
      scheduledDate: tz.TZDateTime.now(
        tz.local,
      ).add(Duration(minutes: minutes)),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_channel',
          'Todo Reminders',
          channelDescription: 'یادآوری کارها',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);
  }
}
