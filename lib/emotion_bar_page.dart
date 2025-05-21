import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';

class EmotionBarPage extends StatefulWidget {
  const EmotionBarPage({Key? key}) : super(key: key);

  @override
  State<EmotionBarPage> createState() => _EmotionStatsPageState();
}

class _EmotionStatsPageState extends State<EmotionBarPage> {
  DateTime _focusedMonth = DateTime.now();

  final List<String> emotionKeys = ['angry', 'neutral', 'happy', 'sad', 'bad'];

  final Map<String, String> emotionImagePaths = {
    'angry': 'assets/emotions/angry.png',
    'neutral': 'assets/emotions/neutral.png',
    'happy': 'assets/emotions/happy.png',
    'sad': 'assets/emotions/sad.png',
    'bad': 'assets/emotions/bad.png',
  };

  final Map<String, Color> emotionColors = {
    'angry': const Color.fromARGB(255, 125, 28, 28),
    'neutral': const Color.fromARGB(255, 255, 136, 0),
    'happy': const Color.fromARGB(255, 0, 255, 128),
    'sad': const Color.fromARGB(255, 255, 247, 13),
    'bad': const Color.fromARGB(255, 255, 0, 0),
  };

  Map<String, int> _getEmotionCounts(Box<DiaryEntry> box) {
    final Map<String, int> counts = {for (var key in emotionKeys) key: 0};
    for (final entry in box.values) {
      if (entry.date.year == _focusedMonth.year &&
          entry.date.month == _focusedMonth.month) {
        final emotion = entry.emotion;
        if (counts.containsKey(emotion)) {
          counts[emotion] = counts[emotion]! + 1;
        }
      }
    }
    return counts;
  }

  String _getFeedbackMessage(Map<String, int> counts) {
    final total = counts.values.fold(0, (a, b) => a + b);
    if (total == 0) return '이번 달에는 작성된 감정 기록이 없어요.';

    final negativeScore = (counts['neutral'] ?? 0) + (counts['sad'] ?? 0);
    final positiveScore = (counts['happy'] ?? 0);

    if (negativeScore > total * 0.5) {
      return '이번 달은 마음이 조금 무거웠나 봐요.\n유독 감정에 구름이 많았던 달이었어요. \n하지만 햇살도 틈틈이 곁에 있었을 거예요.\n그 작은 빛들을 기억해봐요.';
    } else if (positiveScore > total * 0.5) {
      return '이 달은 감정의 파도가 부드럽게 이어졌어요.\n마음을 눌렀던 순간도 있었지만\n그만큼 웃는 날도 있었던 한 달이네요.\n정말 수고했어요 :)';
    } else {
      return '감정은 다양하게 흘러가요.\n기쁨도, 슬픔도 모두 당신의 한 부분이에요.\n이번 달도 잘 지나왔어요. 정말 수고했어요 :)';
    }
  }

  String _getSolutionImage(Map<String, int> counts) {
    final total = counts.values.fold(0, (a, b) => a + b);
    final positive = counts['happy'] ?? 0;
    final negative = (counts['neutral'] ?? 0) + (counts['sad'] ?? 0);

    // 피드백

    if (total == 0) return 'assets/solution/solution_sunny.png'; // 기본값 sunny이미지
    if (negative > total * 0.5) {
      // 우울+슬픔이 전체 50% 넘으면
      return 'assets/solution/solution_moon.png';
    } else if (positive > total * 0.5) {
      // 행복이 전체의 50% 넘으면
      return 'assets/solution/solution_sunny.png';
    } else {
      // 감정이 골고루 섞여있을 때
      return 'assets/solution/solution_rainbow.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<DiaryEntry>('diaryEntries');
    final emotionCounts = _getEmotionCounts(box);
    final feedbackMessage = _getFeedbackMessage(emotionCounts);
    final imagePath = _getSolutionImage(emotionCounts);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDEB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  const SizedBox(height: 3),
                  const Icon(
                    FontAwesomeIcons.chartSimple,
                    size: 24,
                    color: Color.fromARGB(255, 24, 19, 19),
                  ),
                  const SizedBox(height: 8),
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
                      const SizedBox(width: 16),
                      Text(
                        DateFormat('yyyy년 M월').format(_focusedMonth),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 16),
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
                  const SizedBox(height: 6),
                  const Text(
                    '감정 통계',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50), // 날짜와 그래프 간격
            AspectRatio(
              aspectRatio: 1.2,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      axisNameSize: 80,
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
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
            const SizedBox(height: 70), // 피드백 상자와 그래프 간격격
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
                        imagePath,
                        width: 45,
                        height: 45,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        feedbackMessage,
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
