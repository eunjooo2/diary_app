import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // ✅ FontAwesome 사용

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
            const FaIcon(FontAwesomeIcons.gear, size: 28), // ✅ 설정 아이콘 교체
            const SizedBox(height: 8),
            const Divider(thickness: 1),

            _buildSettingItem(
              icon: FontAwesomeIcons.lock, // 🔒
              text: '화면 암호 설정',
              onTap: () {
                // TODO: 암호 설정 페이지로 이동
              },
            ),
            _buildSettingItem(
              icon: FontAwesomeIcons.rotateRight, // 🔄
              text: '화면 암호 변경',
              onTap: () {
                // TODO: 암호 변경 페이지로 이동
              },
            ),

            const Divider(thickness: 1),

            _buildSwitchItem(
              icon: FontAwesomeIcons.bell, // 🔔
              text: '일기 알림',
              value: isNotificationOn,
              onChanged: (value) {
                setState(() {
                  isNotificationOn = value;
                });
              },
            ),
            _buildSettingItem(
              icon: FontAwesomeIcons.circleInfo, // ℹ️
              text: '앱 정보',
              onTap: () {
                // TODO: 앱 정보 다이얼로그
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
      leading: FaIcon(icon, color: Colors.black87), // ✅ FontAwesome 아이콘 사용
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
      secondary: FaIcon(icon, color: Colors.black87), // ✅ FontAwesome 아이콘 사용
      title: Text(text, style: const TextStyle(fontSize: 16)),
      value: value,
      onChanged: onChanged,
    );
  }
}
