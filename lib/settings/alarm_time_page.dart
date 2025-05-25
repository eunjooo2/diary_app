/*
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:daily_app/settings/alarm.dart';

class AlarmTimePage extends StatefulWidget {
  const AlarmTimePage({super.key});

  @override
  State<AlarmTimePage> createState() => _AlarmTimePageState();
}

class _AlarmTimePageState extends State<AlarmTimePage> {
  TimeOfDay selectedTime = const TimeOfDay(hour: 21, minute: 0);

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
      final now = DateTime.now();
      final scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      await notificationsPlugin.zonedSchedule(
        0,
        '오늘 하루는 어땠나요?',
        '감정을 기록해보세요 📝',
        scheduledTime.isBefore(tz.TZDateTime.now(tz.local))
            ? scheduledTime.add(const Duration(days: 1))
            : scheduledTime,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDEB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDEB),
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.clockRotateLeft,
              color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '알림 시간 설정',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _pickTime,
          child: const Text('시간 선택하기'),
        ),
      ),
    );
  }
}

*/
