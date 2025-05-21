import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// 알림 플러그인 전역 인스턴스
final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// 알림 초기화 함수 (main.dart에서 호출해야 함)
Future<void> initializeNotifications() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);

  await notificationsPlugin.initialize(initSettings);
}

/// 매일 밤 9시에 알림 예약
Future<void> showDailyNotification() async {
  final now = tz.TZDateTime.now(tz.local);
  final scheduled =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, 21, 0);

  await notificationsPlugin.zonedSchedule(
    0,
    '오늘 하루는 어땠나요?',
    '감정을 기록해보세요 📝',
    scheduled.isBefore(now)
        ? scheduled.add(const Duration(days: 1))
        : scheduled,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        '감정일기 알림',
        channelDescription: '매일 감정을 기록할 수 있도록 알려줍니다.',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidAllowWhileIdle: true,
    matchDateTimeComponents: DateTimeComponents.time,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.wallClockTime,
  );
}
