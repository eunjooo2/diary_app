import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'calendar_page.dart';
import 'settings_page.dart';
import 'write_page.dart';

class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});

  @override
  State<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  int _selectedIndex = 0;
  TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';

  final List<Map<String, String>> diaryEntries = const [
    {
      'emotionImg': 'happy.png',
      'weatherImg': 'sunny.png',
      'date': '2025년 03월 27일 목요일',
      'text': '오전 수업 끝나고 교수님께 상담을 받으러 갔다. 고민됐던 게 해결돼서 후련했다. 열심히 해야지',
    },
    {
      'emotionImg': 'bad.png',
      'weatherImg': 'cloud.png',
      'date': '2025년 03월 26일 수요일',
      'text': '산학 프로젝트 때문에 저녁에 다시 학교에 모여 회의를 했다. 집에 가는데 날씨가 너무 추웠다.',
    },
    {
      'emotionImg': 'depressed.png',
      'weatherImg': 'rain.png',
      'date': '2025년 03월 25일 화요일',
      'text': '오늘따라 유난히 피곤한 하루였다. 곧 3월이 끝나가네.. 시간이 너무 빠른 것 같다.',
    },
    {
      'emotionImg': 'smile.png',
      'weatherImg': 'snow.png',
      'date': '2025년 03월 18일 화요일',
      'text': '3월인데 눈이 왔다. 3월에는 눈 보다니 신기했다. 너무 추웠지만 약간 예뻤다.',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDiaryListView() {
    final filteredEntries = diaryEntries.where((entry) {
      return entry['text']!.contains(_searchKeyword);
    }).toList();

    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '감정 일기 리스트',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchKeyword = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: '검색어를 입력하세요.',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Color(0xFFFFFFFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 118, 97, 157)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 211, 177, 227),
                          width: 2,
                        ),
                      ),
                      suffixIcon: const Padding(
                        padding: EdgeInsets.all(15),
                        child:
                            FaIcon(FontAwesomeIcons.magnifyingGlass, size: 18),
                      ),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WritePage()),
                );
                if (result != null && result is String) {
                  print("작성된 감정일기: $result");
                }
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
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
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredEntries.length,
              itemBuilder: (context, index) {
                final entry = filteredEntries[index];

                final emotionPath = entry['emotionImg'] != null
                    ? 'assets/emotions/${entry['emotionImg']}'
                    : 'assets/emotions/default.png';
                final weatherPath = entry['weatherImg'] != null
                    ? 'assets/weather/${entry['weatherImg']}'
                    : 'assets/weather/default.png';

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
                      Column(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.yellow[100],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(emotionPath,
                                  width: 18, height: 18),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(weatherPath,
                                  width: 18, height: 18),
                            ),
                          ),
                        ],
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
      _buildDiaryListView(),
      const CalendarPage(),
      const Placeholder(),
      const Placeholder(),
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
