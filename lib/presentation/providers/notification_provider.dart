
import 'package:flutter/material.dart';
import 'package:sleeprism_app/api/api_service.dart';
import 'package:sleeprism_app/data/models/notification_model.dart';


class NotificationProvider with ChangeNotifier {
  final ApiService _apiService;

  NotificationProvider(this._apiService);

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _apiService.getNotifications();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}