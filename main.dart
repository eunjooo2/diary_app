import 'package:flutter/material.dart';
import 'lock_screen.dart';

void main() {
  runApp(DailyApp());
}

class DailyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '감정 일기',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: 'Roboto',
      ),
      home: lock_screen(), // 앱 실행 시 lock 화면 출력
    );
  }
}

// lock 화면
class lock_screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('오늘의 감정 기록')),
      // body: Center(child: Text('홈 UI 여기에 들어갈 거예요!')),
    );
  }
}
