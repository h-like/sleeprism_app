// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/post_provider.dart';
import 'presentation/screens/main_screen.dart';

void main() {
  // 앱 전체에서 PostProvider를 사용할 수 있도록 등록합니다.
  runApp(
    ChangeNotifierProvider(
      create: (context) => PostProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SleepRism',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MainScreen(), // 첫 화면을 MainScreen으로 변경
    );
  }
}
