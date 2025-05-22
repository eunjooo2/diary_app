import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDEB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFDEB),
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.angleLeft,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 동작
          },
        ),
        title: const Text(
          '앱 정보',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '감정일기 앱 v1.0.0',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '이 앱은 하루하루의 감정을 기록하고, 그 흐름을 돌아볼 수 있도록 도와줍니다. '
              '감정의 변화 과정을 시각적으로 확인하면서, '
              '스스로의 마음을 더 깊이 이해하고 돌볼 수 있는 계기를 제공합니다.\n\n'
              '© 2025 감정일기 개발팀\n'
              '문의: rigverjooa@gmail.com',
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
