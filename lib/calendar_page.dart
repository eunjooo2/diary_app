// 캘린터 페이지 
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import '../models/diary_entry.dart';
import 'write_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage(
      {super.key}); // const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // 감정 이미지 경로
  final Map<String, String> emotionImagePaths = {
    'happy': 'assets/emotions/happy.png',
    'neutral': 'assets/emotions/neutral.png',
    'sad': 'assets/emotions/sad.png',
    'angry': 'assets/emotions/angry.png',
    'bad': 'assets/emotions/bad.png',
  };

  // 날씨 이미지 경로
  final Map<String, String> weatherImagePaths = {
    'sunny': 'assets/weather/sunny.png',
    'cloud': 'assets/weather/cloud.png',
    'rain': 'assets/weather/rain.png',
    'snow': 'assets/weather/snow.png',
  };

  // 도움말 다이얼로그 표시
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFFFE0F6),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '캘린더',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  '작성한 일기는 캘린더에서 \n한 눈에 확인해볼 수가 있어요.\n'
                  '날짜를 선택하면 감정, 날씨, 내용까지 \n자세히 볼 수 있고, 수정이나 삭제도 \n가능해요.',
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 12),
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

  // 날짜(년,월,일)
  DateTime _stripTime(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  // Hive 저장용 키 형식 (yyyy-MM-dd)
  String _formatDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  // 해당 날짜의 일기 가져오기
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
    final selectedRecord =
        selected != null ? _getDiaryEntryByDate(selected) : null;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDEB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              // 상단 바 (아이콘 + 월 이동 + 도움말 버튼)
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
                            const SizedBox(width: 75),
                            Text(
                              '${_focusedDay.year}년 ${_focusedDay.month}월',
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

              // 선택된 날짜 표시
              if (_selectedDay != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR')
                        .format(_selectedDay!),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

              const SizedBox(height: 20),

              // 캘린더 위젯
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
                        color: Colors.orangeAccent, shape: BoxShape.circle),
                    selectedDecoration: BoxDecoration(
                        color: Colors.deepOrange, shape: BoxShape.circle),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                    weekendStyle: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
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

              // 감정일기 미리보기 or 등록 유도
              if (selected != null && selectedRecord != null)
                _buildDiaryPreview(selected, selectedRecord)
              else if (selected != null)
                _buildEmptyEntryBox(),
            ],
          ),
        ),
      ),
    );
  }

  // 감정일기 미리보기 위젯
  Widget _buildDiaryPreview(DateTime selected, DiaryEntry selectedRecord) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 + 수정/삭제 팝업 메뉴
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(selected),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                PopupMenuButton<String>(
                  icon: const FaIcon(FontAwesomeIcons.ellipsisVertical,
                      size: 19, color: Colors.grey),
                  offset: const Offset(0, 30),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE9CFF4), width: 1),
                  ),
                  color: const Color(0xFFFFF0FB),
                  onSelected: (value) async {
                    final box = Hive.box<DiaryEntry>('diaryEntries');
                    final key = _formatDateKey(selected);

                    if (value == 'edit') {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WritePage(
                              selectedDate: selected,
                              existingEntry: selectedRecord),
                        ),
                      );
                      if (result != null) setState(() {});
                    } else if (value == 'delete') {
                      await box.delete(key);
                      setState(() {});
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                        value: 'edit', child: Center(child: Text('✏️ 수정'))),
                    PopupMenuItem(
                        value: 'delete', child: Center(child: Text('🗑 삭제'))),
                  ],
                ),
              ],
            ),
          ),

          // 일기 미리보기 박스
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
                // 감정 + 날씨 아이콘
                Column(
                  children: [
                    if (emotionImagePaths.containsKey(selectedRecord.emotion))
                      _buildCircleImage(
                          emotionImagePaths[selectedRecord.emotion]!, 45),
                    const SizedBox(height: 10),
                    if (weatherImagePaths.containsKey(selectedRecord.weather))
                      Image.asset(
                        weatherImagePaths[selectedRecord.weather]!,
                        width: 25,
                        height: 25,
                        fit: BoxFit.cover,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // 일기 내용 요약
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                      children: [
                        TextSpan(
                          text: (selectedRecord.text?.length ?? 0) > 81
                              ? selectedRecord.text!.substring(0, 80)
                              : (selectedRecord.text ?? '작성된 일기 없음'),
                        ),
                        if ((selectedRecord.text?.length ?? 0) > 80)
                          const TextSpan(
                            text: ' ...(생략)',
                            style: TextStyle(
                              color: Color.fromARGB(255, 146, 146, 146),
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 일기 없는 날: 감정 등록 안내 위젯
  Widget _buildEmptyEntryBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(_selectedDay!),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                const SizedBox(height: 10),
                const Text(
                  '오늘 하루는 어떤 하루였나요?\n오늘의 감정을 기록해주세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 5),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.plus,
                      size: 18, color: Colors.black38),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              WritePage(selectedDate: _selectedDay!)),
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
    );
  }

  // 동그란 감정 아이콘 출력
  Widget _buildCircleImage(String path, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: ClipOval(
        child: Image.asset(path, fit: BoxFit.cover),
      ),
    );
  }
}
