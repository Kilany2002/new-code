class Booking {
  final String playStationName;
  final String roomName;
  final String currentMode;
  final double hourlyRate;
  final double purchaseCost;
  final DateTime startDate;
  final List<Map<String, dynamic>> orders;

  Booking({
    required this.playStationName,
    required this.roomName,
    required this.currentMode,
    required this.hourlyRate,
    required this.purchaseCost,
    required this.startDate,
    required this.orders,
  });
    int get totalMinutes => DateTime.now().difference(startDate).inMinutes;

  double get totalCost => (totalMinutes / 60) * hourlyRate + purchaseCost;
}