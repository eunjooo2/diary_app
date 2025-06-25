import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/diary_entry.dart';
import 'pin_code_page.dart';
import 'diary_list_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:daily_app/settings/alarm.dart'; // 알림 함수들

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  final appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);

  Hive.registerAdapter(DiaryEntryAdapter());
  await Hive.openBox<DiaryEntry>('diaryEntries');
  await Hive.openBox('settings'); // 설정용 (pin_code, 알림)

  // 날짜 포맷 로컬 설정
  await initializeDateFormatting('ko_KR', null);

  // 알림 초기화
  await initializeNotifications();

  // 알림 설정 여부 확인 후 예약
  final settingsBox = Hive.box('settings');
  final isAlarmOn = settingsBox.get('alarm_on', defaultValue: true);
  if (isAlarmOn == true) {
    final hour = settingsBox.get('alarm_hour', defaultValue: 21);
    final minute = settingsBox.get('alarm_minute', defaultValue: 0);
    try {
      await scheduleDailyAlarm(hour, minute);
    } catch (e) {
      print('알림 예약 실패 (main): $e');
    }
  }

  // 암호 설정 여부에 따라 시작 페이지 결정  // 암호 설정 시: 앱실행 시 첫 페이지 -> 암호 페이지
  final savedPin = settingsBox.get('pin_code');

  runApp(MyApp(
    startPage: savedPin == null ? const DiaryListPage() : const PinCodePage(),
  ));
}

class MyApp extends StatelessWidget {
  final Widget startPage;
  const MyApp({required this.startPage, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: startPage,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'), 
        Locale('en'), 
      ],
    );
  }
}
