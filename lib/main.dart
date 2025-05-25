import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'models/diary_entry.dart';
import 'pin_code_page.dart';
import 'diary_list_page.dart';
// import 'package:daily_app/settings/alarm.dart'; // 알림 관련

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  final appDocDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocDir.path);

  Hive.registerAdapter(DiaryEntryAdapter());
  await Hive.openBox<DiaryEntry>('diaryEntries');
  await Hive.openBox('settings'); // pin_code 저장용

  // 날짜 포맷 로컬 설정
  await initializeDateFormatting('ko_KR', null);

  // 알림 초기화 (필요 시)
  // await initializeNotifications();

  // 암호 설정 여부 확인
  final settingsBox = Hive.box('settings');
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
    );
  }
}
