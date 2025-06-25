/// 일기 작성 페이지
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import '../models/diary_entry.dart';

class WritePage extends StatefulWidget {
  final DateTime selectedDate;
  final DiaryEntry? existingEntry;

  const WritePage({
    super.key,
    required this.selectedDate,
    this.existingEntry,
  });

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final TextEditingController _controller = TextEditingController();
  bool _isWriting = false;

  // 감정/날씨 기본값
  String selectedEmotion = 'happy';
  String selectedWeather = 'sunny';

  // 감정 이미지 경로
  final Map<String, String> emotionImagePaths = {
    'happy': 'assets/emotions/happy.png',
    'neutral': 'assets/emotions/neutral.png',
    'sad': 'assets/emotions/sad.png',
    'bad': 'assets/emotions/bad.png',
    'angry': 'assets/emotions/angry.png',
  };

  // 날씨 이미지 경로
  final Map<String, String> weatherImagePaths = {
    'sunny': 'assets/weather/sunny.png',
    'cloud': 'assets/weather/cloud.png',
    'rain': 'assets/weather/rain.png',
    'snow': 'assets/weather/snow.png',
  };

  @override
  void initState() {
    super.initState();

    // 수정 모드일 경우 초기값 설정
    if (widget.existingEntry != null) {
      selectedEmotion = widget.existingEntry!.emotion;
      selectedWeather = widget.existingEntry!.weather;
      _controller.text = widget.existingEntry!.text ?? '';
    }

    _controller.addListener(() {
      setState(() {
        _isWriting = _controller.text.isNotEmpty;
      });
    });
  }

  // 감정 선택 다이얼로그
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

  // 날씨 선택 다이얼로그
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

  // 감정일기 저장 처리
  Future<void> _saveEntry() async {
    final date = widget.selectedDate;
    final formattedKey = DateFormat('yyyy-MM-dd').format(date);

    final entry = DiaryEntry(
      date: date,
      emotion: selectedEmotion,
      weather: selectedWeather,
      text: _controller.text,
    );

    final box = Hive.box<DiaryEntry>('diaryEntries');
    await box.put(formattedKey, entry);

    Navigator.pop(context, {
      'emotion': selectedEmotion,
      'weather': selectedWeather,
      'text': _controller.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('yyyy년 M월 d일 EEEE', 'ko').format(widget.selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDE7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronLeft,
              size: 16, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          formattedDate,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: _saveEntry,
            child: const Text(
              '저장',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),

      // 본문
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // 감정 + 날씨 선택 이미지
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _selectEmotion,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
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

            // 일기 입력창
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
