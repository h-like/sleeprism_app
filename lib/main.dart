// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sleeprism_app/api/api_service.dart';
import 'package:sleeprism_app/presentation/providers/chat_provider.dart';
import 'package:sleeprism_app/presentation/providers/notification_provider.dart';
import 'package:sleeprism_app/presentation/providers/post_provider.dart';
import 'package:sleeprism_app/router/router.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/main_screen.dart';

void main() {
  // ApiService는 Provider 외부에서 생성하여 의존성을 주입합니다.
  final ApiService apiService = ApiService();

  runApp(
    MultiProvider(
      providers: [
        // AuthProvider는 ApiService에 의존합니다.
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => PostProvider(apiService)),
        ChangeNotifierProvider(create: (_) => NotificationProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ChatProvider(apiService)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'SleepRism',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      // home: Consumer<AuthProvider>(
      //   builder: (context, auth, child) {
      //     // 앱 시작 시 자동 로그인 시도
      //     if (auth.authStatus == AuthStatus.uninitialized) {
      //       auth.tryAutoLogin();
      //       return const Scaffold(
      //         body: Center(child: CircularProgressIndicator()),
      //       );
      //     }
      //
      //     switch (auth.authStatus) {
      //       case AuthStatus.authenticating:
      //         return const Scaffold(
      //           body: Center(child: CircularProgressIndicator()),
      //         );
      //       case AuthStatus.authenticated:
      //         return const MainScreen();
      //       case AuthStatus.unauthenticated:
      //       default:
      //         return const LoginScreen();
      //     }
      //   },
      // ),
    );
  }
}
