import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'calendar_page.dart';
import 'settings_page.dart';

class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});

  @override
  State<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  int _selectedIndex = 0;

  final List<Map<String, String>> diaryEntries = const [
    {
      'emoji': '😊',
      'date': '2025년 03월 27일 목요일',
      'text': '오전 수업 끝나고 교수님께 상담을 받으러 갔다. 고민됐던 게 해결돼서 후련했다. 열심히 해야지',
    },
    {
      'emoji': '😞',
      'date': '2025년 03월 26일 수요일',
      'text': '산학학 프로젝트 때문에 저녁에 다시 학교에 모여 회의를 했다. 집에 가는데 날씨가 너무 추웠다.',
    },
    {
      'emoji': '😫',
      'date': '2025년 03월 25일 화요일',
      'text': '오늘따라 유난히 피곤한 하루였다. 곧 3월이 끝나가네.. 시간이 너무 빠른 것 같다.',
    },
    {
      'emoji': '😄',
      'date': '2025년 03월 18일 화요일',
      'text': '3월인데 눈이 왔다. 3월에는 눈 보다니 신기했다. 너무 추웠지만 약간 예뻤다.',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 리스트 UI만 반환 (Scaffold ❌)
  Widget _buildDiaryListView() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '감정 일기 리스트',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                FaIcon(FontAwesomeIcons.magnifyingGlass, size: 20)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    '오늘 하루는 어떤 하루였나요?\n오늘의 감정을 기록하세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  SizedBox(height: 15),
                  FaIcon(FontAwesomeIcons.plus,
                      size: 18, color: Colors.black38),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: diaryEntries.length,
              itemBuilder: (context, index) {
                final entry = diaryEntries[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.yellow[100],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(entry['emoji']!,
                              style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry['date']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              entry['text']!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      )
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
    final List<Widget> pages = [
      _buildDiaryListView(), // 리스트 탭 (index 0)
      const CalendarPage(), // 캘린더 탭 (index 1)
      const Placeholder(), // 그래프 탭 (index 2)
      const Placeholder(), // 분석 탭 (index 3)
      const SettingsPage(), // ✅ 설정 탭 (index 4) ← 이 줄만 바뀜!
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBDB),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 211, 208, 67),
        unselectedItemColor: const Color.fromARGB(91, 94, 94, 94),
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.bars),
            label: '리스트',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.calendarDays),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.faceSmile),
            label: '그래프',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.chartSimple),
            label: '분석',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.gear),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
