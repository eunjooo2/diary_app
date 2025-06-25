import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'diary_list_page.dart';

class PinCodePage extends StatefulWidget {
  const PinCodePage({super.key});

  @override
  State<PinCodePage> createState() => _PinCodePageState();
}

class _PinCodePageState extends State<PinCodePage> {
  final List<String> _pin = [];
  String? _savedPin;
  int _cancelCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedPin(); // 저장된 암호 불러오기
  }

  // Hive에서 암호 불러오기
  Future<void> _loadSavedPin() async {
    final box = await Hive.openBox('settings');
    setState(() {
      _savedPin = box.get('pin_code');
    });
  }

  // 숫자 입력 처리
  void _addDigit(String digit) {
    if (_pin.length < 4) {
      setState(() => _pin.add(digit));
      if (_pin.length == 4) _verifyPin();
    }
  }

  // 암호 일치 확인
  void _verifyPin() {
    final enteredPin = _pin.join('');
    if (enteredPin == _savedPin) {
      Future.delayed(const Duration(milliseconds: 200), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DiaryListPage()),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('암호가 틀렸습니다.')),
      );
      _resetPin();
    }
  }

  // 숫자 하나 지우기
  void _deleteDigit() {
    if (_pin.isNotEmpty) {
      setState(() => _pin.removeLast());
    }
  }

  // 취소(초기화 시도)
  void _resetPin() async {
    _cancelCount++;

    if (_cancelCount >= 6) {
      final box = await Hive.openBox('settings');
      await box.delete('pin_code');

      if (!mounted) return;

      // 초기화 완료 다이얼로그
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFFFFE6F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 8),
              Text(
                '암호 초기화 완료',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.purple[800],
                ),
              ),
            ],
          ),
          content: const Text(
            '암호를 초기화했어요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF444444),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 팝업 닫기
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DiaryListPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      setState(() => _pin.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_savedPin == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 200),
            const Text(
              '암호를 입력해 주세요.',
              style: TextStyle(color: Colors.black38, fontSize: 16),
            ),
            const SizedBox(height: 50),

            // 암호 4자리 표시
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

  // 키패드 행 UI
  Widget _buildKeypadRow(List<String> labels) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: labels.map((label) {
          final isDigit = RegExp(r'^\d$').hasMatch(label);

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
                      color: isDigit
                          ? const Color.fromARGB(255, 237, 247, 255)
                          : const Color.fromARGB(0, 255, 225, 225),
                      width: 0.2,
                    ),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
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
