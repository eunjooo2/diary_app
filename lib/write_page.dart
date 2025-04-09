import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WritePage extends StatefulWidget {
  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final TextEditingController _controller = TextEditingController();
  bool _isWriting = false;

  // 기본 선택된 감정/날씨
  String selectedEmotion = 'happy';
  String selectedWeather = 'sunny';

  final Map<String, String> emotionImagePaths = {
    'happy': 'assets/emotions/happy.png',
    'bad': 'assets/emotions/bad.png',
    'angry': 'assets/emotions/angry.png',
    'depressed': 'assets/emotions/depressed.png',
    'smile': 'assets/emotions/smile.png',
  };

  final Map<String, String> weatherImagePaths = {
    'sunny': 'assets/weather/sunny.png',
    'cloud': 'assets/weather/cloud.png',
    'rain': 'assets/weather/rain.png',
    'snow': 'assets/weather/snow.png',
  };

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isWriting = _controller.text.isNotEmpty;
      });
    });
  }

  void _selectEmotion() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('오늘의 감정을 선택하세요'),
        children: emotionImagePaths.entries.map((entry) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, entry.key),
            child: Row(
              children: [
                Image.asset(entry.value, width: 32, height: 32),
                const SizedBox(width: 10),
                Text(entry.key),
              ],
            ),
          );
        }).toList(),
      ),
    );

    if (result != null) {
      setState(() {
        selectedEmotion = result;
      });
    }
  }

  void _selectWeather() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('오늘의 날씨를 선택하세요'),
        children: weatherImagePaths.entries.map((entry) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, entry.key),
            child: Row(
              children: [
                Image.asset(entry.value, width: 24, height: 24),
                const SizedBox(width: 10),
                Text(entry.key),
              ],
            ),
          );
        }).toList(),
      ),
    );

    if (result != null) {
      setState(() {
        selectedWeather = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        DateFormat('yyyy년 M월 d일 EEEE', 'ko').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.chevronLeft, size: 16,
            color: Colors.black, // 아이콘 색상 설정
          ),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 동작
          },
        ),
        centerTitle: true,
        title: Text(
          formattedDate,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print("일기 저장됨: \${_controller.text}");
              print("선택한 감정: \$selectedEmotion");
              print("선택한 날씨: \$selectedWeather");

              // 감정, 날씨, 텍스트 모두 넘김
              Navigator.pop(context, {
                'emotion': selectedEmotion,
                'weather': selectedWeather,
                'text': _controller.text,
              });
            },
            child: const Text(
              '저장',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 감정 선택 버튼
                GestureDetector(
                  onTap: _selectEmotion,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        emotionImagePaths[selectedEmotion]!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 날씨 선택 버튼
                GestureDetector(
                  onTap: _selectWeather,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                        weatherImagePaths[selectedWeather]!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  autofocus: false,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '오늘은 어떤 하루였나요?\n간단하게 기록해 보아요!',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
