abstract class NotificationRepository {
  Future<void> markNotificationsAsRead(String userId);
}