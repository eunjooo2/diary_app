import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';

class EmotionBarPage extends StatefulWidget {
  const EmotionBarPage({super.key});

  @override
  State<EmotionBarPage> createState() => _EmotionStatsPageState();
}

class _EmotionStatsPageState extends State<EmotionBarPage> {
  DateTime _focusedMonth = DateTime.now();

  final List<String> emotionKeys = ['angry', 'bad', 'sad', 'neutral', 'happy'];

  final Map<String, String> emotionImagePaths = {
    'happy': 'assets/emotions/happy.png',
    'neutral': 'assets/emotions/neutral.png',
    'sad': 'assets/emotions/sad.png',
    'bad': 'assets/emotions/bad.png',
    'angry': 'assets/emotions/angry.png',
  };

  final Map<String, Color> emotionColors = {
    'happy': const Color.fromARGB(255, 0, 255, 128),
    'neutral': const Color.fromARGB(255, 104, 217, 255),
    'sad': const Color.fromARGB(255, 255, 247, 13),
    'bad': const Color.fromARGB(255, 255, 145, 48),
    'angry': const Color.fromARGB(255, 255, 8, 8),
  };

  // 월별 감정 횟수 계산
  Map<String, int> _getEmotionCounts(Box<DiaryEntry> box) {
    final Map<String, int> counts = {for (var key in emotionKeys) key: 0};
    for (final entry in box.values) {
      if (entry.date.year == _focusedMonth.year &&
          entry.date.month == _focusedMonth.month &&
          counts.containsKey(entry.emotion)) {
        counts[entry.emotion] = counts[entry.emotion]! + 1;
      }
    }
    return counts;
  }

  // 감정 요약 메시지 생성
  String _getFeedbackMessage(Map<String, int> counts) {
    final total = counts.values.fold(0, (a, b) => a + b);
    if (total == 0) return '이번 달에는 작성된 감정 기록이 없어요.';

    final negative =
        (counts['bad'] ?? 0) + (counts['angry'] ?? 0) + (counts['sad'] ?? 0);
    final positive = (counts['happy'] ?? 0) + (counts['neutral'] ?? 0);
    final gap = (positive - negative).abs();

    if (negative > total * 0.6) {
      // 부정적 감정이 많은 달
      return '이번 달은 마음이 조금 무거웠나 봐요.\n유독 감정에 구름이 많았던 달이었어요.\n하지만 햇살도 틈틈이 곁에 있었을 거예요.\n그 작은 빛들을 기억해봐요.';
    } else if (positive > total * 0.6) {
      // 긍정적 감정이 많은 달
      return '이 달은 감정의 파도가 부드럽게 이어졌어요. 마음을 눌렀던 순간도 있었지만,\n그만큼 웃는 날도 있었던 한 달이네요.\n정말 수고했어요 :)';
    } else if (gap <= 3) {
      // 감정이 고르게 분포 되어 있는 달
      return '감정은 다양하게 흘러가요. 기쁨도, 슬픔도, 때론 복잡한 마음까지 모두 당신의 한 부분이에요. 어떤 하루든 무의미한 날은 없었어요.\n이번 달도 잘 지나왔어요. 정말 수고했어요 :)';
    }
    return '감정을 분석하는 데 오류가 발생했어요.';
  }

  // 감정 상태에 따른 이미지 경로 반환
  String _getSolutionImage(Map<String, int> counts) {
    final total = counts.values.fold(0, (a, b) => a + b);
    final positive = (counts['happy'] ?? 0) + (counts['neutral'] ?? 0);
    final negative =
        (counts['bad'] ?? 0) + (counts['angry'] ?? 0) + (counts['sad'] ?? 0);

    if (total == 0) return 'assets/solution/solution_sunny.png';
    if (negative > total * 0.6) return 'assets/solution/solution_cloud.png';
    if (positive > total * 0.6) return 'assets/solution/solution_sunny.png';
    return 'assets/solution/solution_rainbow.png';
  }

  // 도움말 다이얼로그
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFFFE0F6),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('이달의 감정 요약',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text(
                '이번 달의 감정 기록을 바 그래프로 정리해\n감정 상태를 한눈에 확인할 수 있어요.',
                style: TextStyle(fontSize: 15, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<DiaryEntry>('diaryEntries');
    final emotionCounts = _getEmotionCounts(box);
    final feedback = _getFeedbackMessage(emotionCounts);
    final solutionImage = _getSolutionImage(emotionCounts);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDEB),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더 + 월 이동 + 도움말 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const Icon(FontAwesomeIcons.chartSimple, size: 23),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.chevronLeft,
                                size: 16),
                            color: Colors.grey[500],
                            onPressed: () {
                              setState(() {
                                _focusedMonth = DateTime(
                                  _focusedMonth.year,
                                  _focusedMonth.month - 1,
                                );
                              });
                            },
                          ),
                          const SizedBox(width: 75),
                          Text(
                            DateFormat('yyyy년 M월').format(_focusedMonth),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(width: 75),
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.chevronRight,
                                size: 16),
                            color: Colors.grey[500],
                            onPressed: () {
                              final now = DateTime.now();
                              if (_focusedMonth.year < now.year ||
                                  (_focusedMonth.year == now.year &&
                                      _focusedMonth.month < now.month)) {
                                setState(() {
                                  _focusedMonth = DateTime(
                                    _focusedMonth.year,
                                    _focusedMonth.month + 1,
                                  );
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      const Text(
                        '이달의 감정 요약',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: -10,
                    child: IconButton(
                      icon: const FaIcon(FontAwesomeIcons.circleInfo,
                          color: Color.fromARGB(255, 255, 200, 241), size: 18),
                      onPressed: _showHelpDialog,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 50),

            // 감정 바 차트
            AspectRatio(
              aspectRatio: 1.2,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 68,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < emotionKeys.length) {
                            final emotion = emotionKeys[index];
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 10),
                                Image.asset(
                                  emotionImagePaths[emotion]!,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${emotionCounts[emotion]}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: List.generate(emotionKeys.length, (index) {
                    final key = emotionKeys[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: emotionCounts[key]!.toDouble(),
                          color: emotionColors[key],
                          width: 35,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 감정 피드백 박스
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Image.asset(
                        solutionImage,
                        width: 45,
                        height: 45,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        feedback,
                        style: const TextStyle(fontSize: 14, height: 1.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
