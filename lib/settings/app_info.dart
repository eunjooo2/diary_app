import 'package:flutter/material.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDEB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDEB),
        elevation: 0,
        title: const Text(
          '앱 정보',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '감정일기 앱 v1.0.0',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '이 앱은 매일의 감정을 기록하고, 감정의 흐름을 분석하여\n'
              '자신의 마음을 더 잘 이해할 수 있도록 도와줍니다.\n\n'
              '© 2025 감정일기 개발팀\n'
              '문의: emotion.diary@app.com',
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
