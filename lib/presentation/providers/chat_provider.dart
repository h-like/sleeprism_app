
import 'package:flutter/material.dart';
import 'package:sleeprism_app/api/api_service.dart';
import 'package:sleeprism_app/data/models/chat_room_model.dart';


class ChatProvider with ChangeNotifier {
  final ApiService _apiService;

  ChatProvider(this._apiService);

  List<ChatRoomModel> _chatRooms = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatRoomModel> get chatRooms => _chatRooms;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchChatRooms() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _chatRooms = await _apiService.getChatRooms();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}