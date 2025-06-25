/// 암호 설정 페이지
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class PasswordSettingPage extends StatefulWidget {
  const PasswordSettingPage({super.key});

  @override
  State<PasswordSettingPage> createState() => _PasswordSettingPageState();
}

class _PasswordSettingPageState extends State<PasswordSettingPage> {
  List<String> _pin = [];
  String? _tempPassword;
  bool _isConfirming = false;

  // 숫자 입력 처리
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

  // 초기화
  void _resetPin() => setState(() => _pin.clear());
  void _deleteDigit() => setState(() {
        if (_pin.isNotEmpty리 입력 박스
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

  // 키패드 줄 생성 함수
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
