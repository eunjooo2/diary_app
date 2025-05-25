import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:daily_app/models/diary_entry.dart';
import 'package:intl/intl.dart';

class EmotionLinePage extends StatefulWidget {
  const EmotionLinePage({super.key});

  @override
  State<EmotionLinePage> createState() => _EmotionLinePageState();
}

class _EmotionLinePageState extends State<EmotionLinePage> {
  List<Map<String, dynamic>> weeklyEmotionData = [];
  DateTime _focusedMonth = DateTime.now();

  final Map<String, int> emotionToScore = {
    'angry': -2,
    'bad': -1,
    'sad': 0,
    'neutral': 1,
    'happy': 2,
  };

  final Map<int, Color> scoreColors = {
    -2: const Color.fromARGB(255, 255, 17, 0),
    -1: const Color.fromARGB(255, 255, 135, 22),
    0: Colors.amber,
    1: const Color.fromARGB(255, 0, 174, 255),
    2: const Color.fromARGB(255, 0, 175, 6),
  };

  final Map<int, String> emotionImages = {
    -2: 'assets/emotions/angry.png',
    -1: 'assets/emotions/bad.png',
    0: 'assets/emotions/sad.png',
    1: 'assets/emotions/neutral.png',
    2: 'assets/emotions/happy.png',
  };

  @override
  void initState() {
    super.initState();
    loadEmotionData();
  }

  void loadEmotionData() async {
    final box = await Hive.openBox<DiaryEntry>('diaryEntries');
    final entries = box.values.toList();

    final data = calculateWeeklyEmotionData(
      entries,
      _focusedMonth.year,
      _focusedMonth.month,
    );

    setState(() {
      weeklyEmotionData = data;
    });
  }

  void changeMonth(int offset) {
    final newMonth = DateTime(_focusedMonth.year, _focusedMonth.month + offset);
    final now = DateTime.now();
    final isFuture = newMonth.year > now.year ||
        (newMonth.year == now.year && newMonth.month > now.month);

    if (!isFuture) {
      setState(() {
        _focusedMonth = newMonth;
      });
      loadEmotionData();
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 255, 224, 246),
        title: const Text('이달의 감정 흐름'),
        content: const Text(
            '한 달 동안의 감정 변화를 주차 단위로 정리해 선 그래프로 표현했어요. 이번달 나의 감정의 흐름을 살펴보세요.'),
        actions: [
          TextButton(
            child: const Text('확인'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  List<Map<String, dynamic>> calculateWeeklyEmotionData(
      List<DiaryEntry> entries, int year, int month) {
    final filtered = entries
        .where((e) => e.date.year == year && e.date.month == month)
        .toList();

    Map<int, List<String>> weeklyEmotions = {1: [], 2: [], 3: [], 4: [], 5: []};

    for (final entry in filtered) {
      int day = entry.date.day;
      int week = ((day - 1) ~/ 7) + 1;
      if (week >= 1 && week <= 5) {
        weeklyEmotions[week]!.add(entry.emotion);
      }
    }

    List<Map<String, dynamic>> weeklyData = [];
    for (int i = 1; i <= 5; i++) {
      final emotions = weeklyEmotions[i]!;
      if (emotions.isEmpty) {
        weeklyData.add({'score': 0, 'emotion': null});
      } else {
        final freq = <String, int>{};
        for (final e in emotions) {
          freq[e] = (freq[e] ?? 0) + 1;
        }
        final mostFrequent =
            freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
        final score = emotionToScore[mostFrequent] ?? 0;
        weeklyData.add({'score': score, 'emotion': mostFrequent});
      }
    }

    return weeklyData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDEB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Stack(
                children: [
                  Column(
                    children: [
                      const Icon(FontAwesomeIcons.chartLine,
                          size: 23, color: Color.fromARGB(255, 24, 19, 19)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.chevronLeft,
                                size: 16),
                            color: Colors.grey[500],
                            onPressed: () => changeMonth(-1),
                          ),
                          const SizedBox(width: 82),
                          Text(
                            DateFormat('yyyy년 M월').format(_focusedMonth),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(width: 82),
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.chevronRight,
                                size: 16),
                            color: Colors.grey[500],
                            onPressed: () => changeMonth(1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      const Text(
                        '이달의 감정 흐름',
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
            const SizedBox(height: 35),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: LineChart(
                  LineChartData(
                    minY: -2.3,
                    maxY: 2.3,
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1.0,
                          reservedSize: 36,
                          getTitlesWidget: (value, meta) {
                            if (value >= 0 && value <= 4) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text('${value.toInt() + 1}주차',
                                    style: const TextStyle(fontSize: 12)),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1.0,
                          getTitlesWidget: (value, _) {
                            if (value > 2 || value < -2) {
                              return const SizedBox.shrink();
                            }
                            return Transform.translate(
                              offset: const Offset(0, -4),
                              child: Text(
                                value.toInt().toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          weeklyEmotionData.length,
                          (index) => FlSpot(
                            index.toDouble(),
                            weeklyEmotionData[index]['score'].toDouble(),
                          ),
                        ),
                        isCurved: true,
                        curveSmoothness: 0.15,
                        color: const Color.fromARGB(255, 245, 198, 255),
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            final score = weeklyEmotionData[index]['score'];
                            final color = scoreColors[score] ?? Colors.grey;

                            return FlDotCirclePainter(
                              radius: 4,
                              color: color,
                              strokeWidth: 0,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final topRow = [2, 1];
    final bottomRow = [0, -1, -2];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: topRow.map((score) => _legendItem(score)).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: bottomRow.map((score) => _legendItem(score)).toList(),
        ),
      ],
    );
  }

  Widget _legendItem(int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(emotionImages[score]!, width: 24, height: 24),
          const SizedBox(width: 20),
          Text(_emotionLabel(score), style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  String _emotionLabel(int score) {
    switch (score) {
      case -2:
        return " 화남 -2";
      case -1:
        return " 나쁨 -1";
      case 0:
        return " 슬픔  0";
      case 1:
        return " 보통 +1";
      case 2:
        return " 행복 +2";
      default:
        return "";
    }
  }
}
