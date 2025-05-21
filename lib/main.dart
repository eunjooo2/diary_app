import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/diary_entry.dart';
import 'pin_code_page.dart';
import 'package:daily_app/settings/alarm.dart'; // 알림 함수들 import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeNotifications(); //  알림 초기화
  await initializeDateFormatting('ko_KR', null);

  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  Hive.registerAdapter(DiaryEntryAdapter());
  await Hive.openBox<DiaryEntry>('diaryEntries');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: PinCodePage());
  }
}
