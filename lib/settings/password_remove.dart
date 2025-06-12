import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class PasswordRemovePage extends StatefulWidget {
  const PasswordRemovePage({super.key});

  @override
  State<PasswordRemovePage> createState() => _PasswordRemovePageState();
}

class _PasswordRemovePageState extends State<PasswordRemovePage> {
  List<String> _pin = [];
  int _cancelCount = 0;
  String? _errorMessage;

  // 숫자 입력 처리
  void _addDigit(String digit) async {
    _cancelCount = 0;
    if (_pin.length >= 4) return;

    setState(() => _pin.add(digit));

    if (_pin.length == 4) {
      final inputPin = _pin.join();
      final box = await Hive.openBox('settings');
      final savedPin = box.get('pin_code') ?? '';

      if (inputPin == savedPin) {
        await box.delete('pin_code');
        if (mounted) {
          await _showDialog(
            title: '암호 제거 완료',
            message: '암호가 성공적으로\n제거되었습니다.',
          );
          Navigator.pop(context);
        }
      } else {
        setState(() => _pin.clear());
        await _showDialog(
          title: '앗, 틀렸어요!',
          message: '입력하신 암호가 맞지 않아요.\n다시 한 번 확인해볼까요?',
        );
      }
    }
  }

  // 취소 버튼 누르면 연속 횟수로 초기화
  void _resetPin() async {
    _cancelCount++;
    if (_cancelCount >= 6) {
      final box = await Hive.openBox('settings');
      await box.delete('pin_code');

      if (mounted) {
        await _showDialog(
          title: '암호 초기화 완료',
          message: '암호를 초기화했어요!',
        );
        Navigator.pop(context);
      }
    } else {
      setState(() => _pin.clear());
    }
  }

  // 지우기 (1자리 삭제)
  void _deleteDigit() {
    _cancelCount = 0;
    setState(() {
      if (_pin.isNotEmpty) _pin.removeLast();
    });
  }

  // 공통 다이얼로그
  Future<void> _showDialog(
      {required String title, required String message}) async {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFFE6F0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.purple[800])),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: Color(0xFF444444)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 안내 문구
  String get _guideText => '기존 암호를 입력하세요';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 200),
            Text(
              _guideText,
              style: const TextStyle(color: Colors.black38, fontSize: 16),
            ),
            const SizedBox(height: 50),

            // PIN 입력칸
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      _pin.length > index ? '●' : '',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                );
              }),
            ),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            const Spacer(),

            // 키패드
            SizedBox(
              height: 280,
              child: Container(
                color: Colors.yellow[100],
                child: Column(
                  children: [
                    _buildKeypadRow(['1', '2', '3']),
                    _buildKeypadRow(['4', '5', '6']),
                    _buildKeypadRow(['7', '8', '9']),
                    _buildKeypadRow(['취소', '0', '지우기']),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 키패드 버튼 Row 구성
  Widget _buildKeypadRow(List<String> labels) {
    final isDigit = RegExp(r'^\d$');

    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: labels.map((label) {
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (label == '지우기') {
                    _deleteDigit();
                  } else if (label == '취소') {
                    _resetPin();
                  } else {
                    _addDigit(label);
                  }
                },
                splashColor: const Color.fromARGB(255, 252, 255, 230),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDigit.hasMatch(label)
                          ? const Color.fromARGB(255, 237, 247, 255)
                          : Colors.transparent,
                      width: 0.2,
                    ),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
