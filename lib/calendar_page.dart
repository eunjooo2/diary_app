import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import '../models/diary_entry.dart';
import 'write_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<String, String> emotionImagePaths = {
    'happy': 'assets/emotions/happy.png',
    'angry': 'assets/emotions/angry.png',
    'bad': 'assets/emotions/bad.png',
    'neutral': 'assets/emotions/neutral.png',
    'sad': 'assets/emotions/sad.png',
  };

  final Map<String, String> weatherImagePaths = {
    'sunny': 'assets/weather/sunny.png',
    'cloud': 'assets/weather/cloud.png',
    'rain': 'assets/weather/rain.png',
    'snow': 'assets/weather/snow.png',
  };

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 255, 224, 246),
        title: const Text('캘린더'),
        content: const Text(
            '작성한 일기의 감정은 달력에서 바로 확인할 수 있어요. 날짜를 선택하면 감정, 날씨, 내용까지 자세히 볼 수 있고, 수정이나 삭제도 가능해요.'),
        actions: [
          TextButton(
            child: const Text('확인'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  DateTime _stripTime(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _formatDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  DiaryEntry? _getDiaryEntryByDate(DateTime date) {
    final box = Hive.box<DiaryEntry>('diaryEntries');
    return box.get(_formatDateKey(date));
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDay != null ? _stripTime(_selectedDay!) : null;
    final DiaryEntry? selectedRecord =
        selected != null ? _getDiaryEntryByDate(selected) : null;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDEB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const Icon(FontAwesomeIcons.calendar,
                            size: 23, color: Color.fromARGB(255, 24, 19, 19)),
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
                                  _focusedDay = DateTime(
                                      _focusedDay.year, _focusedDay.month - 1);
                                  _selectedDay = null;
                                });
                              },
                            ),
                            const SizedBox(width: 82),
                            Text(
                              '${_focusedDay.year}년 ${_focusedDay.month}월',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(width: 82),
                            IconButton(
                              icon: const FaIcon(FontAwesomeIcons.chevronRight,
                                  size: 16),
                              color: Colors.grey[500],
                              onPressed: () {
                                final now = DateTime.now();
                                final isFuture = _focusedDay.year > now.year ||
                                    (_focusedDay.year == now.year &&
                                        _focusedDay.month >= now.month);
                                if (!isFuture) {
                                  setState(() {
                                    _focusedDay = DateTime(_focusedDay.year,
                                        _focusedDay.month + 1);
                                    _selectedDay = null;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: -10,
                      right: 0,
                      child: IconButton(
                        icon: const FaIcon(FontAwesomeIcons.circleInfo,
                            color: Color.fromARGB(255, 255, 200, 241),
                            size: 18),
                        onPressed: _showHelpDialog,
                      ),
                    ),
                  ],
                ),
              ),
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
                height: 330,
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
                      final record = _getDiaryEntryByDate(day);
                      if (record != null &&
                          emotionImagePaths.containsKey(record.emotion)) {
                        return Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            child: ClipOval(
                              child: Image.asset(
                                emotionImagePaths[record.emotion]!,
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
              // 아래는 일기 박스 관련 UI 그대로 유지
              if (selected != null && selectedRecord != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR')
                                  .format(selected),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const FaIcon(
                                  FontAwesomeIcons.ellipsisVertical,
                                  size: 19,
                                  color: Colors.grey),
                              offset: const Offset(0, 30),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              onSelected: (value) async {
                                final box =
                                    Hive.box<DiaryEntry>('diaryEntries');
                                final formattedKey =
                                    DateFormat('yyyy-MM-dd').format(selected);
                                if (value == 'edit') {
                                  final entry = box.get(formattedKey);
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => WritePage(
                                        selectedDate: selected,
                                        existingEntry: entry,
                                      ),
                                    ),
                                  );
                                  if (result != null) setState(() {});
                                } else if (value == 'delete') {
                                  await box.delete(formattedKey);
                                  setState(() {});
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'edit', child: Text('수정')),
                                PopupMenuItem(
                                    value: 'delete', child: Text('삭제')),
                              ],
                            ),
                          ],
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
                                    .containsKey(selectedRecord.emotion))
                                  Container(
                                    width: 45,
                                    height: 45,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Image.asset(
                                        emotionImagePaths[
                                            selectedRecord.emotion]!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                if (weatherImagePaths
                                    .containsKey(selectedRecord.weather))
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(1),
                                    child: Image.asset(
                                      weatherImagePaths[
                                          selectedRecord.weather]!,
                                      width: 25,
                                      height: 25,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                selectedRecord.text ?? '작성된 일기 없음',
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
                              icon: const FaIcon(FontAwesomeIcons.plus,
                                  size: 18, color: Colors.black38),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        WritePage(selectedDate: _selectedDay!),
                                  ),
                                );
                                if (result != null) {
                                  setState(() {});
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
