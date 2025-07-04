/// 암호 변경 페이지
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class PasswordChangePage extends StatefulWidget {
  const PasswordChangePage({super.key});

  @override
  State<PasswordChangePage> createState() => _PasswordChangePageState();
}

// 단계 구분
enum _Step {
  verifyCurrent,
  enterNew,
  confirmNew,
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  List<String> _pin = [];
  String? _tempNewPassword;
  String? _savedPassword;
  _Step _currentStep = _Step.verifyCurrent;

  @override
  void initState() {
    super.initState();
    _loadSavedPassword();
  }

  Future<void> _loadSavedPassword() async {
    final box = await Hive.openBox('settings');
    setState(() {
      _savedPassword = box.get('pin_code');
    });
  }

  // 숫자 입력 처리
  void _addDigit(String digit) {
    if (_pin.length >= 4) return;
    setState(() => _pin.add(digit));

    if (_pin.length == 4) {
      final entered = _pin.join();

      switch (_currentStep) {
        case _Step.verifyCurrent:
          if (entered == _savedPassword) {
            _resetPin();
            setState(() => _currentStep = _Step.enterNew);
          } else {
            _showDialog(
              title: '앗, 틀렸어요!',
              message: '기존 암호가 맞지 않아요.\n다시 한 번 확인해볼까요?',
            );
            _resetPin();
          }
          break;

        case _Step.enterNew:
          _tempNewPassword = entered;
          _resetPin();
          setState(() => _currentStep = _Step.confirmNew);
          break;

        case _Step.confirmNew:
          if (entered == _tempNewPassword) {
            _saveNewPassword(entered);
          } else {
            _showDialog(
              title: '앗, 틀렸어요!',
              message: '새 암호가 일치하지 않아요.\n처음부터 다시 입력해 주세요.',
            );
            _resetPin();
            setState(() => _currentStep = _Step.enterNew);
          }
          break;
      }
    }
  }

  void _deleteDigit() {
    setState(() {
      if (_pin.isNotEmpty) _pin.removeLast();
    });
  }

  void _resetPin() {
    setState(() => _pin.clear());
  }

  void _saveNewPassword(String pin) async {
    final box = await Hive.openBox('settings');
    await box.put('pin_code', pin);

    if (mounted) {
      await _showDialog(
        title: '암호 변경 완료',
        message: '암호가 성공적으로\n변경되었습니다.',
      );
      Navigator.pop(context); // 설정 페이지 등으로 돌아가기
    }
  }

  Future<void> _showDialog({required String title, required String message}) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFFFE6F0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.purple[800],
              ),
            ),
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
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  String get _guideText {
    switch (_currentStep) {
      case _Step.verifyCurrent:
        return '기존 암호를 입력하세요';
      case _Step.enterNew:
        return '새 암호 4자리를 입력하세요';
      case _Step.confirmNew:
        return '한 번 더 입력하세요';
    }
  }

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

            // 암호 코드 4자리 입력 박스
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

  // 키패드 한 줄 생성
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
