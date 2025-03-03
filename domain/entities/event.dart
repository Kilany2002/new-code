class EventEntity {
  final String id;
  final String gameName;
  final String conType;
  final String place;
  final int numSub;
  final double price;
  final String imageUrl;
  final DateTime startDate;

  EventEntity({
    required this.id,
    required this.gameName,
    required this.conType,
    required this.place,
    required this.numSub,
    required this.price,
    required this.imageUrl,
    required this.startDate,
  });
}