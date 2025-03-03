import 'package:e7gezly/domain/entities/notification.dart';

import '../repositories/user_repository.dart';

class GetNotifications {
  final UserRepository repository;

  GetNotifications(this.repository);

  Stream<List<Notification>> execute(String userId) {
    return repository.listenToNotifications(userId);
  }
}