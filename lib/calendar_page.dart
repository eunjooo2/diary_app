import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'write_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, Map<String, String>> _dailyRecords = {};

  final Map<String, String> emotionImagePaths = {
    'happy': 'assets/emotions/happy.png',
    'angry': 'assets/emotions/angry.png',
    'bad': 'assets/emotions/bad.png',
    'depressed': 'assets/emotions/depressed.png',
    'smile': 'assets/emotions/smile.png',
  };

  final Map<String, String> weatherImagePaths = {
    'sunny': 'assets/weather/sunny.png',
    'cloud': 'assets/weather/cloud.png',
    'rain': 'assets/weather/rain.png',
    'snow': 'assets/weather/snow.png',
  };

  DateTime _stripTime(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDay != null ? _stripTime(_selectedDay!) : null;
    final selectedRecord = selected != null ? _dailyRecords[selected] : null;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDEB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Center(
                  child: FaIcon(FontAwesomeIcons.calendar, size: 26)), //달력 이미지
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.chevronLeft, size: 16),
                    onPressed: () {
                      setState(() {
                        _focusedDay = DateTime(
                          _focusedDay.year,
                          _focusedDay.month - 1,
                        );
                        _selectedDay = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_focusedDay.year}년 ${_focusedDay.month}월',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.chevronRight, size: 16),
                    onPressed: () {
                      final nextMonth = DateTime(
                        _focusedDay.year,
                        _focusedDay.month + 1,
                      );
                      if (!nextMonth.isAfter(DateTime.now())) {
                        setState(() {
                          _focusedDay = nextMonth;
                          _selectedDay = null;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_selectedDay != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR')
                        .format(_selectedDay!),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                height: 330, // 캘린더와 감정등록 카드 사이 간격
                child: TableCalendar(
                  firstDay: DateTime(2020),
                  lastDay: DateTime.now(),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (selectedDay.isAfter(DateTime.now())) return;
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                      _selectedDay = null;
                    });
                  },
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  headerVisible: false,
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.deepOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                    weekendStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final simpleDay = _stripTime(day);
                      final record = _dailyRecords[simpleDay];

                      print(
                          '📅 ${simpleDay.toIso8601String()} → 감정: ${record?['emotion']}');

                      if (record != null &&
                          emotionImagePaths.containsKey(record['emotion'])) {
                        return Center(
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                emotionImagePaths[record['emotion']]!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }

                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 0.5),
              if (selected != null && selectedRecord != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR')
                              .format(selected),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                if (emotionImagePaths
                                    .containsKey(selectedRecord['emotion']))
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      emotionImagePaths[
                                          selectedRecord['emotion']]!,
                                      width: 51,
                                      height: 51,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                const SizedBox(height: 28),
                                if (weatherImagePaths
                                    .containsKey(selectedRecord['weather']))
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(1),
                                    child: Image.asset(
                                      weatherImagePaths[
                                          selectedRecord['weather']]!,
                                      width: 30,
                                      height: 30,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                selectedRecord['text'] ?? '작성된 일기 없음',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else if (selected != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR')
                              .format(selected),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              '오늘 하루는 어떤 하루였나요?\n오늘의 감정을 기록해주세요!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            IconButton(
                              icon: const FaIcon(
                                FontAwesomeIcons.plus,
                                size: 18,
                                color: Colors.black38,
                              ),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => WritePage(),
                                  ),
                                );

                                if (result != null &&
                                    result is Map<String, String> &&
                                    _selectedDay != null) {
                                  setState(() {
                                    final dateKey = _stripTime(_selectedDay!);
                                    _dailyRecords[dateKey] = result;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
