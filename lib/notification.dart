import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


class Notifications {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void initNotifications() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_launcher'); //TODO Icon
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: null);
  }

  Future<void> pushNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'push_messages: 0', 'push_messages: push_messages', 'push_messages: Add contacts',
      importance: Importance.defaultImportance,
      priority: Priority.low,
      showWhen: false,
      enableVibration: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'Add contacts', 'Did you add all your contacts for today already?', platformChannelSpecifics,
        payload: 'item x');
  }


  tz.TZDateTime nextInstance(TimeOfDay pickedTime) {//TODO Do I really need tz?
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
    print(scheduledDate);
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
            priority: Priority.low,
            enableVibration: false,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, matchDateTimeComponents: DateTimeComponents.time);
  }
}

