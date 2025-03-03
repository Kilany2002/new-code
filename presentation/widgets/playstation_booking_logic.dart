import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/notification_service.dart';
import '../../domain/usecases/fetch_playstation_details_usecase.dart';

class BookingHelper {
  final BookingUseCase useCase;

  BookingHelper({required this.useCase});

  Future<void> updateHourlyRate({
    required String playStationId,
    required String roomId,
    required String console,
    required String mode,
    required Function(double) onRateUpdated,
  }) async {
    double rate = await useCase.getHourlyRate(
      playStationId,
      roomId,
      console,
      mode,
    );
    onRateUpdated(rate);
  }

  Future<bool> selectTime({
  required BuildContext context,
  required DateTime selectedDate,
  required String playStationId,
  required String roomId,
  required Function(TimeOfDay?) onTimeSelected,
}) async {
  DateTime now = DateTime.now();
  bool isBookingForToday = selectedDate.year == now.year &&
      selectedDate.month == now.month &&
      selectedDate.day == now.day;

  TimeOfDay? selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    helpText: tr('choose_start_time').tr(),
  );

  if (selectedTime != null) {
    DateTime selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    if (isBookingForToday && selectedDateTime.isBefore(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('cannot_choose_past_time')).tr()),
      );
      return false;
    }

    QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
        .collection('play_stations')
        .doc(playStationId)
        .collection('rooms')
        .doc(roomId)
        .collection('bookings')
        .where('startDate', isEqualTo: selectedDateTime)
        .get();

    onTimeSelected(selectedTime);
    return bookingSnapshot.docs.isEmpty;
  }
  return true;
}
  Future<void> requestBooking({
    required BuildContext context,
    required String playStationId,
    required String roomId,
    required DateTime startDateTime,
    required String currentMode,
    required double hourlyRate,
    required Function(bool) onLoadingChanged,
    required Function(String) onSuccess,
  }) async {
    onLoadingChanged(true);

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('user_not_logged_in')).tr()),
      );
      onLoadingChanged(false);
      return;
    }

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (userDoc.exists) {
      String fullName = '${userDoc['firstName']} ${userDoc['lastName']}';
      await useCase.requestBooking(
        playStationId: playStationId,
        roomId: roomId,
        startDateTime: startDateTime,
        currentMode: currentMode,
        hourlyRate: hourlyRate,
        user: user,
        fullName: fullName,
      );

      String? managerFcmToken =
          await useCase.fetchPlayStationManagerToken(playStationId);
      if (managerFcmToken != null) {
        NotificationsServices().sendNotification(
          fcmToken: managerFcmToken,
          title: tr('e7gezly').tr(),
          body:
              '${tr('booking_request').tr()}: $fullName, ${tr('room')}, ${startDateTime.toLocal()}',
        );
      }
    }

    onLoadingChanged(false);
    Navigator.of(context).pop();
    onSuccess(tr('booking_success').tr());
  }
}