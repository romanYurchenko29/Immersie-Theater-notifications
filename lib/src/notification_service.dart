import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzl;
import 'package:timezone/standalone.dart' as tz;
import 'package:timezone/standalone.dart';

class NotificationService {
  final _fcmInstance = FirebaseMessaging.instance;
  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  late AndroidNotificationChannel channel;
  Future<void> init() async {
    await _fcmInstance.requestPermission();
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  Future<void> showTimeOutNotification() async {
    await init();
    channel = const AndroidNotificationChannel(
      '01',
      'timeout_channel',
      description: "channel for sending '8-hours left' notifications",
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Вы не дослушали спектакль.',
      'Через 8 часов он пропадёт без возможности восстановелния.',
      _schedule16Hours(),
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: null,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> sendOnNewPlaceNotification() async {
    await init();
    channel = const AndroidNotificationChannel(
      '02',
      'new_place_channel',
      description: "channel for sending 'you're on a new place' notifications",
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Вы пришли на контрольную точку.',
      '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: null,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  TZDateTime _schedule16Hours() {
    tzl.initializeTimeZones();
    var name = tz.timeZoneDatabase.locations.keys.first;
    var loc = getLocation(name);
    return TZDateTime.now(loc).add(const Duration(hours: 16));
  }
}
