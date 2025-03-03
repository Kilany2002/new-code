import 'package:e7gezly/domain/usecases/get_user.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/notification.dart' as custom;
import '../../domain/usecases/get_notifications.dart';

class HomeViewModel with ChangeNotifier {
  final GetUserData _getUserData;
  final GetNotifications _getNotifications;

  HomeViewModel(this._getUserData, this._getNotifications);

  User? _user;
  List<custom.Notification> _notifications = [];
  bool _isLoading = true;

  User? get user => _user;
  List<custom.Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = auth.FirebaseAuth.instance.currentUser!.uid;
      _user = await _getUserData.execute(userId);
      _notifications = await _getNotifications.execute(userId).first;
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}