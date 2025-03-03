import 'package:e7gezly/domain/entities/notification.dart';
import 'package:e7gezly/domain/entities/user.dart';

abstract class UserRepository {
  Future<User> getUser(String userId);
  Future<void> updateUserImage(String userId, String imageUrl);
  Future<void> deleteUserImage(String userId);
  Stream<User> listenToUser(String userId);
  Stream<List<Notification>> listenToNotifications(String userId);
  Future<void> updateFcmToken(String userId, String token);
}