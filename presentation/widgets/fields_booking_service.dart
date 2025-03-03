import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:e7gezly/core/constants/notification_service.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> updateBookingStatus(
      String hourLabel,
      String formattedDate,
      String placeId,
      String userId,
      String userName,
      double totalPrice,
      double bookingPrice) async {
    try {
      DocumentSnapshot fieldSnapshot = await _firestore.collection('football_fields').doc(placeId).get();
      if (!fieldSnapshot.exists) {
        throw Exception('Field not found.');
      }

      String fieldName = fieldSnapshot['name'] ?? 'Unknown Field';
      String ownerId = fieldSnapshot['user_id'] ?? '';

      if (ownerId.isEmpty) {
        throw Exception('Owner ID not found.');
      }
      await _firestore.collection('football_fields').doc(placeId).update({
        'hours.$formattedDate.$hourLabel': {
          'isBooked': true,
          'userName': userName,
          'totalPaid': totalPrice,
          'bookingPrice': bookingPrice,
          'bookedByUserId': userId,
          'timestamp': FieldValue.serverTimestamp(),
        }
      });
      await sendNotificationToUser(userId, fieldName, hourLabel, totalPrice, formattedDate);
      await sendNotificationToOwner(ownerId, fieldName, hourLabel, bookingPrice, formattedDate);
    } catch (e) {
      print('Error updating booking status: $e');
      throw e; 
    }
  }
  Future<void> sendNotificationToUser(
      String userId, String fieldName, String hour, double totalPrice, String formattedDate) async {
    try {
      await _firestore.collection('users').doc(userId).collection('notifications').add({
        'title': 'You booked $fieldName',
        'body':
            'Booked hour: $hour on $formattedDate and paid $totalPrice ${tr('currency')}.',
        'timestamp': FieldValue.serverTimestamp(),
        'icon': 'sports_tennis',
      });
    } catch (e) {
      print('Error sending notification to the user: $e');
    }
  }
  Future<void> sendNotificationToOwner(
      String ownerId, String fieldName, String hour, double bookingPrice, String formattedDate) async {
    try {
      DocumentSnapshot ownerSnapshot = await _firestore.collection('users').doc(ownerId).get();
      String ownerFcmToken = ownerSnapshot['fcmToken'] ?? '';

      if (ownerFcmToken.isNotEmpty) {
        NotificationsServices notificationsServices = NotificationsServices();
        await notificationsServices.sendNotification(
          fcmToken: ownerFcmToken,
          title: 'New booking at $fieldName',
          body:
              'Booked hour: $hour on $formattedDate and paid $bookingPrice ${tr('currency')}.',
        );
      } else {
        print('Owner FCM token not found.');
      }
    } catch (e) {
      print('Error sending notification to the field owner: $e');
    }
  }
}