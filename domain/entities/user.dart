class User {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;
  final double points;


  User({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
    required this.points,
  });

  get profileImageUrl => null;
}