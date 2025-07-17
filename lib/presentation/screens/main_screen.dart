// lib/presentation/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:sleeprism_app/presentation/screens/explore_screen.dart';
import 'package:sleeprism_app/presentation/screens/profile_screen.dart';
import 'package:sleeprism_app/presentation/screens/sound_mixer_screen.dart';
import 'post_list_screen.dart'; // 게시글 목록 화면

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 현재 선택된 탭의 인덱스

  // 하단 메뉴바에 표시될 페이지 목록
  static const List<Widget> _widgetOptions = <Widget>[
    PostListScreen(), // 0번: 홈 (게시글 목록)
    ExploreScreen(),
    SoundMixerScreen(), // 2번: 음악 믹서
    Center(child: Text('알림', style: TextStyle(fontSize: 30))), // 3번: 알림
    ProfileScreen(), // 4번: 내 정보
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 본문에는 선택된 인덱스에 해당하는 위젯을 표시
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: '탐색'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'asmr'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: '알림'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: '내 정보'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이템 색상
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // 탭이 많아도 고정된 형태로 보여줌
        showUnselectedLabels: false, // 선택된 탭의 라벨만 표시하여 깔끔하게
      ),
    );
  }
}
