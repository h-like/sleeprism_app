import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sleeprism_app/api/api_service.dart';
import 'package:sleeprism_app/presentation/providers/auth_provider.dart';
import 'package:sleeprism_app/presentation/providers/chat_detail_provider.dart';
import 'package:sleeprism_app/presentation/screens/chat_screen.dart';
import 'package:sleeprism_app/presentation/screens/login_screen.dart';
import 'package:sleeprism_app/presentation/screens/main_screen.dart';
import 'package:sleeprism_app/presentation/screens/post_detail_screen.dart';
import 'package:sleeprism_app/presentation/screens/sale_request_screen.dart';

GoRouter createAppRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/splash', // 초기 화면을 Splash나 로딩 화면으로 설정
    // ▼▼▼ [핵심] AuthProvider의 상태 변경을 감지합니다. ▼▼▼
    refreshListenable: authProvider,
    routes: [
      // 앱의 모든 화면을 정의합니다.
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
          path: '/',
          builder: (context, state) => const MainScreen(),
          // ▼▼▼ 중첩 라우트(Nested Route)를 사용하여 MainScreen 하위의 화면들을 정의할 수 있습니다.
          routes: [
            GoRoute(
              path: 'posts/:postId',
              builder: (context, state) {
                final postId = int.parse(state.pathParameters['postId']!);
                return PostDetailScreen(postId: postId);
              },
            ),
            GoRoute(
              path: 'chat/rooms/:chatRoomId',
              builder: (context, state) {
                final chatRoomId = int.parse(state.pathParameters['chatRoomId']!);
                // ▼▼▼ [핵심] ChatScreen을 ChangeNotifierProvider로 감싸서 ChatDetailProvider를 주입합니다. ▼▼▼
                return ChangeNotifierProvider(
                  create: (context) => ChatDetailProvider(
                    context.read<ApiService>(), // MultiProvider에 등록되지 않았으므로 context.read로 ApiService 가져오기
                    context.read<AuthProvider>(),
                  ),
                  child: ChatScreen(chatRoomId: chatRoomId),
                );
              },
            ),
            GoRoute(
              path: 'sale-requests/:saleRequestId',
              builder: (context, state) {
                final saleRequestId = int.parse(state.pathParameters['saleRequestId']!);
                return SaleRequestScreen(saleRequestId: saleRequestId);
              },
            ),
          ]
      ),
    ],
    // ▼▼▼ [핵심] 리디렉션 로직 ▼▼▼
    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = authProvider.authStatus;
      final location = state.uri.toString();

      // 아직 인증 상태가 확인되지 않았다면, 로딩 화면에 머무릅니다.
      if (authStatus == AuthStatus.uninitialized || authStatus == AuthStatus.authenticating) {
        return '/splash';
      }

      final isLoggedIn = authStatus == AuthStatus.authenticated;
      final isLoggingIn = location == '/login';

      // 로그인하지 않은 상태에서 로그인 페이지가 아닌 다른 곳으로 가려고 하면
      if (!isLoggedIn && !isLoggingIn) {
        // 로그인 페이지로 보냅니다.
        return '/login';
      }

      // 로그인한 상태에서 로그인 페이지로 가려고 하면
      if (isLoggedIn && (isLoggingIn || location == '/splash')) {
        // 메인 페이지로 보냅니다.
        return '/';
      }

      // 그 외의 경우는 사용자가 요청한 경로로 그대로 보냅니다.
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
}