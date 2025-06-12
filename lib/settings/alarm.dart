// 알림 기능 관련 설정 및 예약 함수 정의
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// 알림 플러그인 인스턴스 (전역에서 사용)
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// 알림 시스템 초기화
Future<void> initializeNotifications() async {
  // 타임존 데이터 초기화
  tz.initializeTimeZones();

  // 안드로이드 알림 초기화 설정 (앱 아이콘 사용)
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // 플랫폼별 초기화 설정 모음
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  // 알림 시스템에 설정 적용
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

///  매일 정해진 시간에 알림 예약
Future<void> scheduleDailyAlarm(int hour, int minute) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0, // 알림 ID (중복 예약 방지용 고정값)
    '오늘 하루 감정, 기록했나요?', // 제목
    '하루 감정을 짧게라도 남겨보세요.', // 내용
    _nextInstanceOfTime(hour, minute), // 알림 예정 시각
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'diary_alarm_channel', // 알림 채널 ID
        '일일 감정 알림', // 알림 채널 이름
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidAllowWhileIdle: true, // 절전모드에서도 울림 허용
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시간 반복
  );
}

/// 예약된 알림 취소
Future<void> cancelAlarm() async {
  await flutterLocalNotificationsPlugin.cancel(0); // ID로 지정한 알림 취소
}

/// 다음 알림 시간 계산 함수
tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  final scheduled =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

  // 현재 시간보다 과거면 다음 날로 예약
  return scheduled.isBefore(now)
      ? scheduled.add(const Duration(days: 1))
      : scheduled;
}
