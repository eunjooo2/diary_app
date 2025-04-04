import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, String> _emotions = {};

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);
    _selectedDay = DateTime.now();
  }

  DateTime _stripTime(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDay != null ? _stripTime(_selectedDay!) : null;
    final selectedEmotion = selected != null ? _emotions[selected] : null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20), // 하단 여백 추가
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Center(child: FaIcon(FontAwesomeIcons.calendar, size: 26)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.chevronLeft, size: 16),
                  onPressed: () {
                    setState(() {
                      _focusedDay =
                          DateTime(_focusedDay.year, _focusedDay.month - 1);
                      _selectedDay = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  '${_focusedDay.year}년 ${_focusedDay.month}월',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.chevronRight, size: 16),
                  onPressed: () {
                    final nextMonth =
                        DateTime(_focusedDay.year, _focusedDay.month + 1);
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
            const SizedBox(height: 12),
            if (_selectedDay != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(_selectedDay!),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 20), //캘린더더
            SizedBox(
              height: 360,
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
                    //현재 날짜
                    color: Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    //선택된 날짜
                    color: Colors.deepOrange,
                    shape: BoxShape.circle,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  // 캘린더 상단에 있는 요일들 설정
                  weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                  weekendStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    if (day.isAfter(DateTime.now())) {
                      return Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 2),
            if (selected != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
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
                      child: selectedEmotion != null
                          ? Text(
                              selectedEmotion,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            )
                          : Column(
                              children: [
                                const Text(
                                  '오늘 하루는 어떤 하루였나요?\n오늘의 감정을 기록해주세요!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 20),
                                IconButton(
                                  icon:
                                      const Icon(Icons.add, color: Colors.grey),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EmotionEditorPage(date: selected),
                                      ),
                                    );
                                    if (result != null && result is String) {
                                      setState(() {
                                        _emotions[selected] = result;
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
    );
  }
}

class EmotionEditorPage extends StatefulWidget {
  final DateTime date;
  const EmotionEditorPage({super.key, required this.date});

  @override
  State<EmotionEditorPage> createState() => _EmotionEditorPageState();
}

class _EmotionEditorPageState extends State<EmotionEditorPage> {
  final TextEditingController _controller = TextEditingController();

  void _save() {
    Navigator.pop(context, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    //감정 작성페이지
    return Scaffold(
      appBar: AppBar(title: const Text('감정 등록')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              DateFormat('yyyy년 M월 d일', 'ko_KR').format(widget.date),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '오늘의 감정을 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: const Text('저장하기'),
            )
          ],
        ),
      ),
    );
  }
}
