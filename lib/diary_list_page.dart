// # 일기 리스트 페이지

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import 'calendar_page.dart';
import 'settings/settings_page.dart';
import 'write_page.dart';
import 'emotion_bar_page.dart';
import 'emotion_line_page.dart';

class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});

  @override
  State<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  int _selectedIndex = 0;
  TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';
  DateTime? _searchDate;
  List<bool> _expandedStates = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDiaryListView() {
    final box = Hive.box<DiaryEntry>('diaryEntries');
    final entries = box.values.toList().reversed.toList();

    final filteredEntries = entries.where((entry) {
      final matchesDate = _searchDate == null ||
          DateFormat('yyyy-MM-dd').format(entry.date) ==
              DateFormat('yyyy-MM-dd').format(_searchDate!);
      final matchesKeyword = _searchKeyword.isEmpty ||
          (entry.text?.toLowerCase().contains(_searchKeyword.toLowerCase()) ??
              false);
      return matchesDate && matchesKeyword;
    }).toList();

    if (_expandedStates.length != filteredEntries.length) {
      _expandedStates = List.generate(filteredEntries.length, (_) => false);
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '감정 일기 리스트',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.calendar, size: 18),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          locale: const Locale('ko'),
                        );
                        if (picked != null) {
                          setState(() {
                            _searchDate = picked;
                          });
                        }
                      },
                    ),
                    if (_searchDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _searchDate = null;
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchKeyword = value;
                });
              },
              decoration: InputDecoration(
                hintText: '검색어를 입력하세요.',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: const Color.fromARGB(255, 255, 236, 253),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 162, 9, 192),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 236, 190, 255),
                    width: 2,
                  ),
                ),
                suffixIcon: IconButton(
                  icon:
                      const FaIcon(FontAwesomeIcons.magnifyingGlass, size: 18),
                  onPressed: () {},
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WritePage(selectedDate: DateTime.now()),
                  ),
                );
                if (result != null && mounted) {
                  setState(() {});
                }
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 250, 254),
                  border: Border.all(
                      color: const Color.fromARGB(255, 239, 182, 255)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '오늘 하루는 어떤 하루였나요?\n오늘의 감정을 기록하세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color.fromARGB(95, 134, 0, 103)),
                    ),
                    SizedBox(height: 15),
                    FaIcon(FontAwesomeIcons.plus,
                        size: 18, color: Color.fromARGB(95, 102, 18, 82)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredEntries.length,
              itemBuilder: (context, index) {
                final entry = filteredEntries[index];
                final key = box.keyAt(box.length - 1 - index);
                final emotionPath = 'assets/emotions/${entry.emotion}.png';
                final weatherPath = 'assets/weather/${entry.weather}.png';
                final isExpanded = _expandedStates[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                emotionPath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: Image.asset(
                                weatherPath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Transform.translate(
                          offset: const Offset(0, -13),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: DateFormat(
                                                    'yyyy년 MM월 dd일 ', 'ko_KR')
                                                .format(entry.date),
                                          ),
                                          TextSpan(
                                            text:
                                                '| ${DateFormat('EEEE', 'ko_KR').format(entry.date)}',
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 90, 90, 90),
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    padding: const EdgeInsets.only(left: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(
                                        color: Color(0xFFE9CFF4),
                                        width: 1,
                                      ),
                                    ),
                                    color: const Color(0xFFFFF0FB),
                                    icon: const FaIcon(
                                      FontAwesomeIcons.ellipsis,
                                      size: 16,
                                      color: Color.fromARGB(255, 184, 184, 184),
                                    ),
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => WritePage(
                                              selectedDate: entry.date,
                                              existingEntry: entry,
                                            ),
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
                                          value: 'edit',
                                          child: Center(child: Text('✏️ 수정'))),
                                      PopupMenuItem(
                                          value: 'delete',
                                          child: Center(child: Text('🗑 삭제'))),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              Text(
                                isExpanded || (entry.text?.length ?? 0) <= 70
                                    ? entry.text ?? ''
                                    : '${entry.text!.substring(0, 70)}...',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                              if ((entry.text?.length ?? 0) > 70)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: TextButton.icon(
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _expandedStates[index] =
                                            !_expandedStates[index];
                                      });
                                    },
                                    icon: FaIcon(
                                      isExpanded
                                          ? FontAwesomeIcons.chevronUp
                                          : FontAwesomeIcons.chevronDown,
                                      size: 12,
                                      color: const Color.fromARGB(
                                          255, 184, 149, 199),
                                    ),
                                    label: Text(
                                      isExpanded ? '접기' : '더보기',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color:
                                            Color.fromARGB(255, 184, 149, 199),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDiaryListView(),
      const CalendarPage(),
      const EmotionLinePage(),
      const EmotionBarPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDEB),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 255, 251, 219),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 231, 183, 255),
        unselectedItemColor: const Color.fromARGB(91, 77, 77, 77),
        items: const [
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.bars), label: '리스트'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.calendarDays), label: '캘린더'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.chartLine), label: '분석'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.chartSimple), label: '그래프'),
          BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.gear), label: '설정'),
        ],
      ),
    );
  }
}
