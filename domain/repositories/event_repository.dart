import 'package:e7gezly/domain/entities/event.dart';

abstract class EventRepository {
  Future<EventEntity> getEventDetails(String eventId);
  Future<bool> isUserSubscribed(String eventId, String userId);
  Future<int> getRemainingSpots(String eventId);
  Future<void> subscribeToEvent(String eventId, String userId);
}