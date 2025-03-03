import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/playstation_repository_impl.dart';

class BookingUseCase {
  final RoomRepository _repository = RoomRepository();

  Future<double> getHourlyRate(String playStationId, String roomId, String consoleType, String mode) async {
    return _repository.getHourlyRate(playStationId, roomId, consoleType, mode);
  }

  Future<String?> fetchPlayStationManagerToken(String playStationId) async {
    return _repository.fetchPlayStationManagerToken(playStationId);
  }

  Future<void> requestBooking({
    required String playStationId,
    required String roomId,
    required DateTime startDateTime,
    required String currentMode,
    required double hourlyRate,
    required User user,
    required String fullName,
  }) async {
    await _repository.requestBooking(
      playStationId: playStationId,
      roomId: roomId,
      startDateTime: startDateTime,
      currentMode: currentMode,
      hourlyRate: hourlyRate,
      user: user,
      fullName: fullName,
    );
  }
}