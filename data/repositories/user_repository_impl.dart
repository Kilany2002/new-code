import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e7gezly/domain/entities/notification.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;

  final FirebaseStorage storage;

  UserRepositoryImpl(this._firestore, this.storage);

  @override
  Future<User> getUser(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      return User(
        id: userId,
        name: userData['firstName'] ?? 'No Name',
        email: userData['email'] ?? 'No Email',
        imageUrl: userData['image_url'],
        points: (userData['points'] ?? 0).toDouble(),
      );
    }
    throw Exception('User not found');
  }

  @override
  Future<void> updateUserImage(String userId, String imageUrl) async {
    await _firestore.collection('users').doc(userId).update({
      'image_url': imageUrl,
    });
  }

  @override
  Future<void> deleteUserImage(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'image_url': FieldValue.delete(),
    });
  }

  @override
  Stream<User> listenToUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        return User(
          id: userId,
          name: userData['firstName'] ?? 'No Name',
          email: userData['email'] ?? 'No Email',
          imageUrl: userData['image_url'],
          points: (userData['points'] ?? 0).toDouble(),
        );
      }
      throw Exception('User not found');
    });
  }

  @override
  Stream<List<Notification>> listenToNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Notification(
          id: doc.id,
          title: data['title'] ?? 'No Title',
          body: data['body'] ?? 'No Body',
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          read: data['read'] ?? false,
          icon: '',
        );
      }).toList();
    });
  }

  @override
  Future<void> updateFcmToken(String userId, String token) {
    // TODO: implement updateFcmToken
    throw UnimplementedError();
  }
}
