import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:daily_app/settings/password_setting.dart';
import 'package:daily_app/settings/password_change.dart';
import 'package:daily_app/settings/app_info.dart';
import 'package:daily_app/settings/alarm.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isNotificationOn = true;
  TimeOfDay selectedTime = const TimeOfDay(hour: 21, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadAlarmSetting();
  }

  Future<void> _loadAlarmSetting() async {
    final box = await Hive.openBox('settings');
    setState(() {
      isNotificationOn = box.get('alarm_on', defaultValue: true);
      final hour = box.get('alarm_hour', defaultValue: 21);
      final minute = box.get('alarm_minute', defaultValue: 0);
      selectedTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _toggleAlarm(bool value) async {
    setState(() => isNotificationOn = value);
    final box = await Hive.openBox('settings');
    await box.put('alarm_on', value);
    if (value) {
      try {
        await scheduleDailyAlarm(selectedTime.hour, selectedTime.minute);
      } catch (e) {
        print('알림 예약 실패 (settings): $e');
      }
    } else {
      await cancelAlarm();
    }
  }

  Future<void> _showCustomTimePicker() async {
    int tempHour = selectedTime.hour;
    int tempMinute = selectedTime.minute;

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFFDEB),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottom) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(FontAwesomeIcons.clock, size: 28),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton<int>(
                        value: tempHour,
                        icon: const FaIcon(FontAwesomeIcons.angleDown,
                            size: 16), // ⬅️ 여기에 추가!
                        items: List.generate(24, (i) {
                          return DropdownMenuItem(
                            value: i,
                            child: Text(i.toString().padLeft(2, '0')),
                          );
                        }),
                        onChanged: (val) =>
                            setStateBottom(() => tempHour = val!),
                      ),
                      const Text(' : '),
                      DropdownButton<int>(
                        value: tempMinute,
                        icon: const FaIcon(FontAwesomeIcons.angleDown,
                            size: 16), // 이거!
                        items: List.generate(60, (i) {
                          return DropdownMenuItem(
                            value: i,
                            child: Text(i.toString().padLeft(2, '0')),
                          );
                        }),
                        onChanged: (val) =>
                            setStateBottom(() => tempMinute = val!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);

                      // 외부 setState로 반영
                      setState(() {
                        selectedTime =
                            TimeOfDay(hour: tempHour, minute: tempMinute);
                      });

                      final box = await Hive.openBox('settings');
                      await box.put('alarm_hour', tempHour);
                      await box.put('alarm_minute', tempMinute);

                      if (isNotificationOn) {
                        await cancelAlarm();
                        try {
                          await scheduleDailyAlarm(tempHour, tempMinute);
                        } catch (e) {
                          print('알림 예약 실패 (custom picker): $e');
                        }
                      }
                    },
                    icon: const FaIcon(FontAwesomeIcons.check),
                    label: const Text("확인"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
              onChanged: _toggleAlarm,
            ),
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
                      Text('알림 시간 설정', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Opacity(
                    opacity: isNotificationOn ? 1.0 : 0.4,
                    child: OutlinedButton(
                      onPressed:
                          isNotificationOn ? _showCustomTimePicker : null,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        backgroundColor: const Color(0xFFFDFBF3),
                      ),
                      child: Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.clock, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            selectedTime.format(context),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87
                                  .withOpacity(isNotificationOn ? 1.0 : 0.4),
                            ),
                          ),
                        ],
                      ),
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
}
