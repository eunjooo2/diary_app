// 주차별 감정 라인그래프
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
  // 주차별 감정 점수 및 대표 감정 데이터 리스트
  List<Map<String, dynamic>> weeklyEmotionData = [];

  // 현재 선택된 달 (기본값: 오늘 기준)
  DateTime _focusedMonth = DateTime.now();

  // 감정-> 점수 매핑
  final Map<String, int> emotionToScore = {
    'angry': -2,
    'bad': -1,
    'sad': 0,
    'neutral': 1,
    'happy': 2,
  };

  // 점수별 색상 설정 (그래프 점 색으로 사용됨)
  final Map<int, Color> scoreColors = {
    -2: const Color.fromARGB(255, 255, 17, 0),
    -1: const Color.fromARGB(255, 255, 135, 22),
    0: Colors.amber, 
    1: const Color.fromARGB(255, 0, 174, 255),
    2: const Color.fromARGB(255, 0, 175, 6),
  };

  // 점수별 감정 이미지 경로
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
    // 페이지가 생성되면 감정 데이터 불러오기
    loadEmotionData();
  }

  // Hive에서 감정 일기 데이터 불러와서 주차별 감정 흐름 계산
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

  // 월 변경 ( 미래 달은 제한 )
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

  // 우측 상단 도움말 버튼 클릭 시 다이얼로그 표시
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFFFFE0F6),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '이달의 감정 흐름',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  '한 달 동안의 감정 변화를 주차 단위로\n 정리해 선 그래프로 표현했어요.\n이번달 나의 감정 흐름을 살펴보세요.',
                  style: TextStyle(fontSize: 15, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('확인', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 해당 월의 일기 데이터를 주차별로 나눠 대표 감정 및 점수를 계산
  List<Map<String, dynamic>> calculateWeeklyEmotionData(
      List<DiaryEntry> entries, int year, int month) {
    // 현재 달에 해당하는 일기만 필터링
    final filtered = entries
        .where((e) => e.date.year == year && e.date.month == month)
        .toList();

    // 각 주차별로 감정을 저장할 맵
    Map<int, List<String>> weeklyEmotions = {1: [], 2: [], 3: [], 4: [], 5: []};

    // 날짜에 따라 주차 구분 후 감정 리스트에 추가
    for (final entry in filtered) {
      int day = entry.date.day;
      int week = ((day - 1) ~/ 7) + 1;
      if (week >= 1 && week <= 5) {
        weeklyEmotions[week]!.add(entry.emotion);
      }
    }

    // 각 주차별 가장 많이 나온 감정을 기준으로 점수 계산
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
            // 상단 헤더: 제목, 월 이동 화살표, 도움말 버튼
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
                            icon: const FaIcon(FontAwesomeIcons.chevronLeft, size: 16),
                            color: Colors.grey[500],
                            onPressed: () => changeMonth(-1),
                          ),
                          const SizedBox(width: 75),
                          Text(
                            DateFormat('yyyy\uB144 M\uC6D4').format(_focusedMonth),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(width: 75),
                          IconButton(
                            icon: const FaIcon(FontAwesomeIcons.chevronRight, size: 16),
                            color: Colors.grey[500],
                            onPressed: () => changeMonth(1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      const Text(
                        '이달의 감정 흐름',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

            // 감정 흐름 선 그래프 (fl_chart)
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
                                child: Text('${value.toInt() + 1}\uC8FC\uCC28',
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
                      rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        // 주차별 점수 데이터로 선형 그래프 구성
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
                          getDotPainter: (spot, percent, barData, index) { // 점의 색깔, 모양 지정
                            final score = weeklyEmotionData[index]['score']; // 주차별 점수 (그 주차에 가장 많이 등록된 감정)
                            final color = scoreColors[score] ?? Colors.grey; // 점수에 맞는 색 가져오기
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

            // 감정 범례 표시
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  // 범례 구성: 점수별 감정 이미지와 설명 텍스트
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

  // 범례의 하나하나 아이템 (이미지 + 텍스트)
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

  // 감정 점수에 따른 텍스트 반환
  String _emotionLabel(int score) {
    switch (score) {
     case -2: 
        return " 화남 -2";
     case -1: 
        return " 우울 -1"; 
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
