import 'package:flutter/material.dart';
import 'pin_code_page.dart';
import 'diary_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DiaryListPage(), // 시작페이지
    );
  }
}
