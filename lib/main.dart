// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/post_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/main_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // AuthProvider의 변경에 따라 PostProvider를 다시 생성할 필요는 없으므로
        // 독립적으로 생성합니다.
        ChangeNotifierProvider(create: (_) => PostProvider()),
      ],
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
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          switch (auth.authStatus) {
            case AuthStatus.uninitialized:
            case AuthStatus.authenticating:
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            case AuthStatus.authenticated:
              return const MainScreen();
            case AuthStatus.unauthenticated:
              return const LoginScreen();
          }
        },
      ),
    );
  }
}