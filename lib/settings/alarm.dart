import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:hive/hive.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

/// 매일 특정 시간에 알림 예약
Future<void> scheduleDailyAlarm(int hour, int minute) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0, // 알림 ID
    '오늘 하루 감정, 기록했나요?',
    '하루 감정을 짧게라도 남겨보세요.',
    _nextInstanceOfTime(hour, minute),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_alarm_channel',
        '일일 감정 알림',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

/// 알림 취소
Future<void> cancelAlarm() async {
  await flutterLocalNotificationsPlugin.cancel(0);
}

/// 다음 알림 시간 계산
tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  final scheduled =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  return scheduled.isBefore(now)
      ? scheduled.add(const Duration(days: 1))
      : scheduled;
}
