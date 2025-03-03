import 'package:cloud_firestore/cloud_firestore.dart';

class RoomDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getRoomDetails(String playStationId, String roomId) async {
    try {
      DocumentSnapshot roomDoc = await _firestore
          .collection('play_stations')
          .doc(playStationId)
          .collection('rooms')
          .doc(roomId)
          .get();

      if (roomDoc.exists && roomDoc.data() != null) {
        return roomDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching room details: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> getPlayStationManagerToken(String playStationId) async {
    try {
      DocumentSnapshot playStationDoc = await _firestore
          .collection('play_stations')
          .doc(playStationId)
          .get();

      if (playStationDoc.exists && playStationDoc.data() != null) {
        String? userId = (playStationDoc.data() as Map<String, dynamic>)['user_id'] as String?;
        if (userId != null) {
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
          if (userDoc.exists && userDoc.data() != null) {
            return userDoc.data() as Map<String, dynamic>;
          }
        }
      }
    } catch (e) {
      print("Error fetching manager token: $e");
    }
    return null;
  }
}