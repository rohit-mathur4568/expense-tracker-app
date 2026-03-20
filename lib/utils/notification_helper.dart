import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize the notification plugin
  static Future<void> init() async {
    // Initialize timezone data required for scheduling
    tz.initializeTimeZones();

    // Setup Android specific initialization settings
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidSettings);

    // FIXED: Naye version mein parameter ka exact naam 'settings' hai
    await _notificationsPlugin.initialize(settings: initSettings);
  }

  // Request permission for Android 13 and above devices
  static Future<void> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  // Schedule the daily reminder
  static Future<void> scheduleDailyReminder() async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Channel for daily expense reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    // Calculate the next time to show notification
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    // 21 represents 9 PM, 0 represents minutes.
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 21, 0);

    // If time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // FIXED: Converted all arguments to named arguments
    await _notificationsPlugin.zonedSchedule(
      id: 0,
      title: 'Expense Reminder',
      body: 'Have you logged all your expenses for today?',
      scheduledDate: scheduledDate,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
  // Cancel the daily reminder
  static Future<void> cancelDailyReminder() async {
    await _notificationsPlugin.cancel(id: 0);
  }
}