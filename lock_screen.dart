import 'package:flutter/material.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  List<String> input = [];

  // 숫자 키패드 입력 처리
  void onKeyTap(String value) {
    setState(() {
      if (value == '지우기' && input.isNotEmpty) {
        input.removeLast();
      } else if (value == '취소') {
        input.clear();
      } else if (input.length < 4 && value != '지우기' && value != '취소') {
        input.add(value);

        if (input.length == 4) {
          const correctPassword = '1234'; // 예시 고정 암호

          if (input.join() == correctPassword) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("암호가 틀렸습니다.")),
            );
            input.clear();
          }
        }
      }
    });
  }

  // 입력된 PIN 점 UI
  Widget buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color:
                index < input.length ? Colors.yellow[600] : Colors.transparent,
            border: Border.all(color: Colors.yellow[600]!, width: 2),
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }

  // 키패드 UI
  Widget buildNumberPad() {
    final buttons = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '취소',
      '0',
      '지우기',
    ];

    return GridView.builder(
      shrinkWrap: true,
      itemCount: buttons.length,
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2,
      ),
      itemBuilder: (context, index) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[100],
            foregroundColor: Colors.grey[800],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => onKeyTap(buttons[index]),
          child: Text(
            buttons[index],
            style: const TextStyle(fontSize: 18),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE7),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Text(
              '암호를 입력해 주세요.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            buildPinDots(),
            const Spacer(),
            buildNumberPad(),
          ],
        ),
      ),
    );
  }
}

// 암호 성공 시 이동할 홈 화면
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("홈 화면")),
      body: const Center(
        child: Text("암호가 일치합니다"),
      ),
    );
  }
}
