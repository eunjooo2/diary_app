// 암호 설정 페이지
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class PasswordSettingPage extends StatefulWidget {
  const PasswordSettingPage({super.key});

  @override
  State<PasswordSettingPage> createState() => _PasswordSettingPageState();
}

class _PasswordSettingPageState extends State<PasswordSettingPage> {
  final List<String> _pin = [];
  String? _tempPassword;
  bool _isConfirming = false;

  void _addDigit(String digit) {
    if (_pin.length >= 4) return;
    setState(() => _pin.add(digit));

    if (_pin.length == 4) {
      final entered = _pin.join();

      if (!_isConfirming) {
        _tempPassword = entered;
        _resetPin();
        setState(() => _isConfirming = true);
      } else {
        if (_tempPassword == entered) {
          _savePassword(entered);
        } else {
          _showDialog(
            title: '앗, 틀렸어요!',
            message: '암호가 일치하지 않아요.\n다시 처음부터 입력해 주세요.',
          );
          _resetPin();
          setState(() => _isConfirming = false);
        }
      }
    }
  }

  void _resetPin() => setState(() => _pin.clear());

  void _deleteDigit() => setState(() {
        if (_pin.isNotEmpty) _pin.removeLast();
      });

  void _savePassword(String password) async {
    final box = await Hive.openBox('settings');
    await box.put('password', password);
    _showDialog(title: '암호 설정 완료!', message: '암호가 성공적으로 저장되었어요.');
    _resetPin();
    setState(() {
      _isConfirming = false;
      _tempPassword = null;
    });
  }

  void _showDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDEB),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Text(
              _isConfirming ? '한 번 더 입력해주세요' : '암호 4자리를 입력해주세요',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),

            // 입력 박스
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
