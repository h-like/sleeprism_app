// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:sleeprism_app/api/api_service.dart';
import 'package:sleeprism_app/presentation/providers/chat_provider.dart';
import 'package:sleeprism_app/presentation/providers/chat_room_list_provider.dart';
import 'package:sleeprism_app/presentation/providers/dream_interpretation_provider.dart';
import 'package:sleeprism_app/presentation/providers/notification_provider.dart';
import 'package:sleeprism_app/presentation/providers/post_provider.dart';
import 'package:sleeprism_app/router/router.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/main_screen.dart';

void main() {
  // ApiService는 Provider 외부에서 생성하여 의존성을 주입합니다.
  // timeago.setLocaleMessages('ko', timeago.KoMessages());
  final ApiService apiService = ApiService();
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey: 'YOUR_NATIVE_APP_KEY');

  runApp(
    MultiProvider(
      providers: [
        // AuthProvider는 ApiService에 의존합니다.
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => DreamInterpretationProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider(apiService)),
        ChangeNotifierProvider(create: (_) => NotificationProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ChatRoomListProvider(apiService)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final router = createAppRouter(authProvider);

    // 앱 시작 시 자동 로그인을 시도합니다.
    // 이 로직은 AuthProvider 생성자나 별도의 초기화 메서드로 옮기는 것이 더 좋습니다.
    if (authProvider.authStatus == AuthStatus.uninitialized) {
      authProvider.tryAutoLogin();
    }

    return MaterialApp.router(
      localizationsDelegates: [
        FlutterQuillLocalizations.delegate, // 이 부분을 추가하세요.
      ],
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'Sleeprism',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
    );
  }
}
