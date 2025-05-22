import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:daily_app/settings/password_setting.dart';
import 'package:daily_app/settings/password_change.dart';
import 'package:daily_app/settings/app_info.dart';
import 'package:daily_app/settings/alarm.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isNotificationOn = true;
  TimeOfDay selectedTime = const TimeOfDay(hour: 21, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDEB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            const FaIcon(FontAwesomeIcons.gear, size: 25),
            const SizedBox(height: 15),
            const Divider(thickness: 1),

            _buildSettingItem(
              icon: FontAwesomeIcons.lock,
              text: '암호 설정',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PasswordSettingPage(),
                  ),
                );
              },
            ),
            _buildSettingItem(
              icon: FontAwesomeIcons.rotateRight,
              text: '암호 변경',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PasswordChangePage(),
                  ),
                );
              },
            ),

            const Divider(thickness: 1),

            _buildSwitchItem(
              icon: FontAwesomeIcons.bell,
              text: '일기 알림',
              value: isNotificationOn,
              onChanged: (value) {
                setState(() => isNotificationOn = value);
                if (value) {
                  showDailyNotification();
                } else {
                  notificationsPlugin.cancelAll();
                }
              },
            ),

            // 알림 시간 설정 버튼 스타일로 추가
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      FaIcon(FontAwesomeIcons.clock,
                          size: 22, color: Colors.black87),
                      SizedBox(width: 17),
                      Text(
                        '알림 시간 설정',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: isNotificationOn ? _pickTime : null,
                    child: Text(
                      selectedTime.format(context),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      backgroundColor: const Color(0xFFFDFBF3),
                    ),
                  ),
                ],
              ),
            ),

            _buildSettingItem(
              icon: FontAwesomeIcons.circleInfo,
              text: '앱 정보',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AppInfoPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String text,
    required VoidCallback? onTap,
  }) {
    return ListTile(
      leading: FaIcon(icon, color: Colors.black87),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String text,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: FaIcon(icon, color: Colors.black87),
      title: Text(text, style: const TextStyle(fontSize: 16)),
      value: value,
      onChanged: onChanged,
    );
  }

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
}
