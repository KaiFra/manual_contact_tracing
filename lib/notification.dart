import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'functions.dart';


class Notifications {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void initNotifications() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@drawable/notif_icon');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: null);
  }

  tz.TZDateTime nextInstance(TimeOfDay pickedTime) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, pickedTime.hour - 1, pickedTime.minute);
    while (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(hours: 1));
    }
    return scheduledDate;
  }

  Future<void> scheduleDailyNotification(TimeOfDay pickedTime) async {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          'Add contacts',
          'Did you add all your contacts for today already?',
          nextInstance(pickedTime),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'daily notification channel id',
              'daily notification channel name',
              'daily notification description',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              enableVibration: false,
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
              .absoluteTime, matchDateTimeComponents: DateTimeComponents.time);
    }
}

