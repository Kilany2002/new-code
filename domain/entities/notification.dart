class Notification {
  final String id;
  final String title;
  final String body;
  final String icon;
  final DateTime timestamp;
  final bool read;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
    required this.timestamp,
    required this.read,
  });
}