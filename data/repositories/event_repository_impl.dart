import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  EventRepositoryImpl({required this.firestore, required this.auth});

  @override
  Future<EventEntity> getEventDetails(String eventId) async {
    final doc = await firestore.collection('events').doc(eventId).get();
    return EventEntity(
      id: eventId,
      gameName: doc['game_name'],
      conType: doc['con_type'],
      place: doc['place'],
      numSub: doc['num_sub'],
      price: doc['price']?.toDouble(),
      imageUrl: doc['image'],
      startDate: (doc['start_date'] as Timestamp).toDate(),
    );
  }

  @override
  Future<bool> isUserSubscribed(String eventId, String userId) async {
    final doc = await firestore
        .collection('events')
        .doc(eventId)
        .collection('participants')
        .doc(userId)
        .get();
    return doc.exists;
  }

  @override
  Future<int> getRemainingSpots(String eventId) async {
    final doc = await firestore.collection('events').doc(eventId).get();
    final participants = await firestore
        .collection('events')
        .doc(eventId)
        .collection('participants')
        .get();
    return doc['num_sub'] - participants.size;
  }

  @override
  Future<void> subscribeToEvent(String eventId, String userId) async {
    final userDoc = await firestore.collection('users').doc(userId).get();
    await firestore
        .collection('events')
        .doc(eventId)
        .collection('participants')
        .doc(userId)
        .set({
      'firstName': userDoc['firstName'],
      'lastName': userDoc['lastName'],
      'phoneNumber': userDoc['phoneNumber'],
      'userId': userId,
    });
    await firestore.collection('events').doc(eventId).update({
      'remaining_spots': await getRemainingSpots(eventId),
    });
  }
}