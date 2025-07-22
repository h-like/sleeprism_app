// GoRouter 설정을 위한 인스턴스 생성
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sleeprism_app/presentation/screens/chat_screen.dart';
import 'package:sleeprism_app/presentation/screens/main_screen.dart';
import 'package:sleeprism_app/presentation/screens/post_detail_screen.dart';
import 'package:sleeprism_app/presentation/screens/sale_request_screen.dart';

final GoRouter router = GoRouter(
  // 앱의 초기 경로 설정
  initialLocation: '/',
  // 경로 목록 정의
  routes: [
    // 홈 화면 (MainScreen)
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScreen(),
    ),
    // 게시글 상세 화면
    GoRoute(
      path: '/posts/:postId', // :postId는 경로 파라미터를 의미
      builder: (context, state) {
        // 경로 파라미터에서 postId를 추출하고 int로 변환
        final postId = int.parse(state.pathParameters['postId']!);
        return PostDetailScreen(postId: postId);
      },
    ),
    // 채팅방 상세 화면
    GoRoute(
      path: '/chat/rooms/:chatRoomId',
      builder: (context, state) {
        final chatRoomId = int.parse(state.pathParameters['chatRoomId']!);
        return ChatScreen(chatRoomId: chatRoomId);
      },
    ),
    // 판매 요청 상세 화면
    GoRoute(
      path: '/sale-requests/:saleRequestId',
      builder: (context, state) {
        final saleRequestId = int.parse(state.pathParameters['saleRequestId']!);
        return SaleRequestScreen(saleRequestId: saleRequestId);
      },
    ),
  ],
  // 에러 발생 시 표시할 화면 (선택 사항)
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(child: Text('Page not found: ${state.error}')),
  ),
);
