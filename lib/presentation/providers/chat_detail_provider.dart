// 이 파일은 특정 채팅방의 상태를 관리합니다. main.dart의 MultiProvider에도 등록해야 합니다.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sleeprism_app/api/api_service.dart';
import 'package:sleeprism_app/data/models/message_model.dart';
import 'package:sleeprism_app/presentation/providers/auth_provider.dart'; // AuthProvider 경로 확인
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatDetailProvider with ChangeNotifier {
  final ApiService _apiService;
  final AuthProvider _authProvider;

  ChatDetailProvider(this._apiService, this._authProvider);

  StompClient? _stompClient;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isConnected = false;
  StreamSubscription? _subscription;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;

  void connectAndListen(int chatRoomId) {
    if (_isConnected) return;

    _isLoading = true;
    _messages.clear();
    notifyListeners();

    // TODO: 실제 WebSocket 주소로 변경해야 합니다.
    const String websocketUrl = 'ws://10.0.2.2:8080/ws';
    final String? token = _authProvider.token;

    if (token == null) {
      _isLoading = false;
      print("Error: Auth token is null. Cannot connect to WebSocket.");
      notifyListeners();
      return;
    }

    _stompClient = StompClient(
      config: StompConfig(
        url: websocketUrl,
        onConnect: (frame) {
          _isConnected = true;
          debugPrint("STOMP client connected");

          // 채팅방 구독
          _subscription = _stompClient!.subscribe(
            destination: '/topic/chat/room/$chatRoomId',
            callback: (frame) {
              if (frame.body != null) {
                final messageData = json.decode(frame.body!);
                final newMessage = ChatMessage.fromJson(messageData);
                _messages.insert(0, newMessage);
                notifyListeners();
              }
            },
          ) as StreamSubscription?;

          // 과거 메시지 요청
          _stompClient!.send(
            destination: '/app/chat.history',
            body: json.encode({'chatRoomId': chatRoomId}),
          );

          // 과거 메시지 수신을 위한 개인 구독
          _stompClient!.subscribe(
              destination: '/user/queue/chat/history/$chatRoomId',
              callback: (frame) {
                if (frame.body != null) {
                  final List<dynamic> historyData = json.decode(frame.body!);
                  final historyMessages = historyData.map((data) => ChatMessage.fromJson(data)).toList();
                  _messages.addAll(historyMessages);
                  _messages.sort((a, b) => b.sentAt.compareTo(a.sentAt)); // 최신순 정렬
                  _isLoading = false;
                  notifyListeners();
                }
              }
          );

          // 입장 메시지 전송
          _stompClient!.send(
            destination: '/app/chat.addUser',
            body: json.encode({'chatRoomId': chatRoomId}),
          );

        },
        beforeConnect: () async {
          debugPrint('Waiting to connect...');
          await Future.delayed(const Duration(milliseconds: 200));
        },
        onWebSocketError: (dynamic error) {
          _isConnected = false;
          _isLoading = false;
          debugPrint("WebSocket Error: ${error.toString()}");
          notifyListeners();
        },
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );

    _stompClient!.activate();
  }

  void sendMessage(int chatRoomId, String content, MessageType type) {
    if (_stompClient == null || !_isConnected) {
      debugPrint("Cannot send message: STOMP client is not connected.");
      return;
    }
    final payload = {
      'chatRoomId': chatRoomId,
      'content': content,
      'messageType': type.toString().split('.').last, // "TEXT" or "IMAGE"
    };
    _stompClient!.send(
      destination: '/app/chat.sendMessage',
      body: json.encode(payload),
    );
  }

  Future<void> pickAndUploadImage(int chatRoomId) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageUrl = await _apiService.uploadChatFile(pickedFile.path);
      if (imageUrl != null) {
        sendMessage(chatRoomId, imageUrl, MessageType.IMAGE);
      } else {
        // TODO: 사용자에게 업로드 실패 알림
        debugPrint("Image upload failed.");
      }
    }
  }

  void disposeConnection() {
    _subscription?.cancel();
    _stompClient?.deactivate();
    _isConnected = false;
    _messages.clear();
    debugPrint("STOMP client deactivated and resources cleared.");
  }
}