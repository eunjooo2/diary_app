import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:daily_app/models/diary_entry.dart';
import 'package:intl/intl.dart';

class EmotionLinePage extends StatefulWidget {
  const EmotionLinePage({super.key});

  @override
  State<EmotionLinePage> createState() => _EmotionTrendPageState();
}

class _EmotionTrendPageState extends State<EmotionLinePage> {
  List<Map<String, dynamic>> weeklyEmotionData = [];
  DateTime currentMonth = DateTime.now();

  final Map<String, int> emotionToScore = {
    'angry': -2,
    'bad': -1,
    'sad': 0,
    'neutral': 1,
    'happy': 2,
  };

  final Map<int, Color> scoreColors = {
    -2: Colors.red,
    -1: Colors.deepOrange,
    0: Colors.amber,
    1: Colors.orange,
    2: Colors.green,
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
      currentMonth.year,
      currentMonth.month,
    );

    setState(() {
      weeklyEmotionData = data;
    });
  }

  void changeMonth(int offset) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + offset);
    });
    loadEmotionData();
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 50),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const FaIcon(FontAwesomeIcons.chartLine, size: 22), // 연결 아이콘
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.chevronLeft, size: 16),
                  onPressed: () => changeMonth(-1),
                ),
                Text(
                  DateFormat.yMMMM('ko_KR').format(currentMonth),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.chevronRight, size: 16),
                  onPressed: () => changeMonth(1),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              '주차별 감정 변화 추이',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: AspectRatio(
                aspectRatio: 0.9,
                child: LineChart(
                  LineChartData(
                    minY: -2,
                    maxY: 2.2,
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        axisNameWidget:
                            const SizedBox.shrink(), // 축 이름이 없으면 shrink
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1.0,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(top: 13), //  아래로 내림
                              child: Text('${value.toInt() + 1}주차',
                                  style: const TextStyle(fontSize: 12)),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1.0,
                          getTitlesWidget: (value, _) {
                            if (value > 2 || value < -2)
                              return const SizedBox.shrink();
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
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
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
                        isCurved: true, // false하면 직선
                        curveSmoothness: 0.15,
                        color: const Color.fromARGB(255, 245, 198, 255),
                        dotData: FlDotData(
                          show: true, // dot 유무
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
            const SizedBox(height: 20),
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
