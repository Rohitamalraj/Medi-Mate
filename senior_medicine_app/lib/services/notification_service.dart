import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/reminder.dart';
import 'tts_service.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._init();

  Future<void> init() async {
    if (kIsWeb) {
      // Web notifications are handled differently
      print('Notifications not fully supported on web, using console logs');
      return;
    }
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Initialize timezone data
    tz_data.initializeTimeZones();
  }

  Future<void> _onNotificationTap(NotificationResponse response) async {
    // When notification is tapped, speak the reminder using enhanced TTS
    if (response.payload != null) {
      await TTSService().speakWithCloudTTS(response.payload!);
    }
  }

  Future<void> scheduleReminder(Reminder reminder) async {
    if (kIsWeb) {
      print('Reminder scheduled for web: ${reminder.medicine} at ${reminder.time}');
      return;
    }
    
    final timeParts = reminder.time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    DateTime scheduledDate = DateTime.now();
    scheduledDate = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      hour,
      minute,
    );

    // If the time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(DateTime.now())) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'medicine_reminders',
      'Medicine Reminders',
      channelDescription: 'Notifications for medicine reminders',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      reminder.id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Medicine Reminder',
      reminder.reminderText,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: reminder.reminderText,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    // For daily reminders, schedule recurring notifications
    if (reminder.frequency == 'daily') {
      await _scheduleRecurringReminder(reminder, scheduledDate);
    }
  }

  Future<void> _scheduleRecurringReminder(Reminder reminder, DateTime firstDate) async {
    // Schedule for the next 30 days
    for (int i = 1; i <= 30; i++) {
      final nextDate = firstDate.add(Duration(days: i));
      
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'medicine_reminders',
        'Medicine Reminders',
        channelDescription: 'Notifications for medicine reminders',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
        enableVibration: true,
        playSound: true,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        (reminder.id ?? 0) + i * 1000, // Unique ID for each occurrence
        'Medicine Reminder',
        reminder.reminderText,
        tz.TZDateTime.from(nextDate, tz.local),
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: reminder.reminderText,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelReminder(int reminderId) async {
    if (kIsWeb) {
      print('Reminder cancelled for web: $reminderId');
      return;
    }
    
    await _flutterLocalNotificationsPlugin.cancel(reminderId);
    
    // Cancel recurring reminders too
    for (int i = 1; i <= 30; i++) {
      await _flutterLocalNotificationsPlugin.cancel(reminderId + i * 1000);
    }
  }

  Future<void> speakReminder(String text, String language) async {
    await TTSService().speakReminder(
      text.split(' ')[0], // medicine name
      text.split(' ')[1], // dose
      DateTime.now().toString().substring(11, 16), // current time
      language: language
    );
  }
}
