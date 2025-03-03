import 'package:e7gezly/domain/repositories/event_repository.dart';

class SubscribeToEventUseCase {
  final EventRepository repository;

  SubscribeToEventUseCase(this.repository);

  Future<void> execute(String eventId, String userId) async {
    await repository.subscribeToEvent(eventId, userId);
  }
}