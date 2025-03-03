import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../datasources/firestore_playstation_datasource.dart';

class RoomRepository {
  final RoomDataSource _dataSource = RoomDataSource();

  Future<double> getHourlyRate(String playStationId, String roomId, String consoleType, String mode) async {
    Map<String, dynamic>? roomData = await _dataSource.getRoomDetails(playStationId, roomId);
    if (roomData == null) return 0.0;

    double? hourlyRate;
    if (consoleType == 'PS5') {
      hourlyRate = mode == 'مالتي'
          ? parseHourlyRate(roomData['ps5MultiHourlyRate'])
          : parseHourlyRate(roomData['ps5SingleHourlyRate']);
    } else {
      hourlyRate = mode == 'مالتي'
          ? parseHourlyRate(roomData['ps4MultiHourlyRate'])
          : parseHourlyRate(roomData['ps4SingleHourlyRate']);
    }
    return hourlyRate ?? 0.0;
  }

  double? parseHourlyRate(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<String?> fetchPlayStationManagerToken(String playStationId) async {
    Map<String, dynamic>? userData = await _dataSource.getPlayStationManagerToken(playStationId);
    return userData?['fcmToken'] as String?;
  }

  Future<void> requestBooking({
    required String playStationId,
    required String roomId,
    required DateTime startDateTime,
    required String currentMode,
    required double hourlyRate,
    required User user,
    required String fullName,
  }) async {
    await FirebaseFirestore.instance
        .collection('play_stations')
        .doc(playStationId)
        .collection('rooms')
        .doc(roomId)
        .collection('booking_requests')
        .add({
      'bookingDate': DateTime.now(),
      'startDate': startDateTime,
      'modeStartTime': startDateTime,
      'endDate': null,
      'roomCost': 0.0,
      'finalCost': 0.0,
      'purchaseCost': 0,
      'totalPeriod': null,
      'currentMode': currentMode,
      'hourlyRate': hourlyRate,
      'type': 'Online',
      'userId': user.uid,
      'userName': fullName,
      'consoleType': currentMode.split('')[0].toUpperCase(),
      'isNew': true,
    });
  }
}