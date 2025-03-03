import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e7gezly/domain/entities/history.dart';

class UserBookingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Booking>> fetchUserBookings(String userId) async {
    List<Booking> bookings = [];
    try {
      QuerySnapshot playStationsSnapshot =
          await _firestore.collection('play_stations').get();
      for (var playStationDoc in playStationsSnapshot.docs) {
        var playStationId = playStationDoc.id;
        var playStationData = playStationDoc.data() as Map<String, dynamic>;
        QuerySnapshot roomsSnapshot = await _firestore
            .collection('play_stations')
            .doc(playStationId)
            .collection('rooms')
            .where('isBooked', isEqualTo: true)
            .get();
        for (var roomDoc in roomsSnapshot.docs) {
          var roomId = roomDoc.id;
          var roomData = roomDoc.data() as Map<String, dynamic>;
          if (roomData['currentBookingId'] != null) {
            DocumentSnapshot bookingDoc = await _firestore
                .collection('play_stations')
                .doc(playStationId)
                .collection('rooms')
                .doc(roomId)
                .collection('bookings')
                .doc(roomData['currentBookingId'])
                .get();
            if (bookingDoc.exists) {
              var bookingData = bookingDoc.data() as Map<String, dynamic>;
              if (bookingData['userId'] == userId) {
                QuerySnapshot purchasesSnapshot = await _firestore
                    .collection('play_stations')
                    .doc(playStationId)
                    .collection('rooms')
                    .doc(roomId)
                    .collection('bookings')
                    .doc(roomData['currentBookingId'])
                    .collection('purchases')
                    .get();
                List<Map<String, dynamic>> orders =
                    purchasesSnapshot.docs.map((purchaseDoc) {
                  var purchaseData = purchaseDoc.data() as Map<String, dynamic>;
                  return {
                    'name': purchaseData['productName'],
                    'price': purchaseData['price'],
                    'quantity': purchaseData['quantity'],
                  };
                }).toList();
                bookings.add(Booking(
                  playStationName: playStationData['name'],
                  roomName: roomData['name'],
                  currentMode: bookingData['currentMode'],
                  hourlyRate: (bookingData['hourlyRate'] as num).toDouble(),
                  purchaseCost: (bookingData['purchaseCost'] as num).toDouble(),
                  startDate: (bookingData['startDate'] as Timestamp).toDate(),
                  orders: orders,
                ));
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching bookings: $e');
    }
    return bookings;
  }
}
