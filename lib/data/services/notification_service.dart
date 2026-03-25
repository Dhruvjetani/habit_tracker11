import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(settings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> showInstantTestNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'habit_tracker_channel',
      'Habit Tracker Notifications',
      channelDescription: 'Habit reminders and updates',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      0,
      title,
      body,
      details,
    );
  }

  Future<void> scheduleHabitReminder({
    required int id,
    required String title,
    required String body,
    required String timeString,
  }) async {
    final parts = timeString.split(':');
    if (parts.length != 2) return;

    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts[1]) ?? 0;

    final scheduledDate = _nextInstanceOfTime(hour, minute);

    const androidDetails = AndroidNotificationDetails(
      'habit_tracker_channel',
      'Habit Tracker Notifications',
      channelDescription: 'Habit reminders and updates',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelHabitNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}