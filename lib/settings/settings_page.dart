import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:daily_app/settings/password_setting.dart';
import 'package:daily_app/settings/password_change.dart';
import 'package:daily_app/settings/app_info.dart';
import 'package:daily_app/settings/alarm.dart'; // 알림 모듈 import

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isNotificationOn = true;

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
                    builder: (context) => const PasswordSettingPage(),
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
                    builder: (context) => const PasswordChangePage(),
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
                setState(() {
                  isNotificationOn = value;
                });
                if (value) {
                  showDailyNotification();
                  // 알림 예약
                } else {
                  notificationsPlugin.cancelAll();
                  //  알림 취소
                }
              },
            ),
            _buildSettingItem(
              icon: FontAwesomeIcons.circleInfo,
              text: '앱 정보',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppInfoPage(),
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
    required VoidCallback onTap,
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
}
