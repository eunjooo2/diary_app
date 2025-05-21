import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordChangePage extends StatefulWidget {
  const PasswordChangePage({super.key});

  @override
  State<PasswordChangePage> createState() => _PasswordChangePageState();
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
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPassword = prefs.getString('pin_code');
    });
  }

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
            _showToast("기존 암호가 일치하지 않습니다.");
            _resetPin();
          }
          break;

        case _Step.enterNew:
          _tempNewPassword = entered;
          _resetPin();
          setState(() => _currentStep = _Step.confirmNew);
          break;

        case _Step.confirmNew:
          if (_tempNewPassword == entered) {
            _saveNewPassword(entered);
          } else {
            _showToast("새 암호가 일치하지 않습니다.");
            _resetPin();
            setState(() => _currentStep = _Step.enterNew);
          }
          break;
      }
    }
  }

  void _resetPin() => setState(() => _pin.clear());

  void _deleteDigit() => setState(() {
        if (_pin.isNotEmpty) _pin.removeLast();
      });

  void _saveNewPassword(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pin_code', pin);
    _showToast("암호가 변경되었습니다.");
    if (mounted) Navigator.pop(context);
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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

enum _Step {
  verifyCurrent,
  enterNew,
  confirmNew,
}
