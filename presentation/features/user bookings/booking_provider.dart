import 'package:flutter/material.dart';
import '../../../data/repositories/booking_repositry.dart';
import '../../../domain/entities/history.dart';

class UserBookingsProvider extends ChangeNotifier {
  final String userId;
  final UserBookingsRepository _repository = UserBookingsRepository();
  List<Booking> _bookings = [];
  bool _isLoading = true;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  UserBookingsProvider(this.userId);

  Future<void> fetchUserBookings() async {
    _isLoading = true;
    notifyListeners();
    _bookings = await _repository.fetchUserBookings(userId);
    _isLoading = false;
    notifyListeners();
  }
}