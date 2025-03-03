class Favorite {
  final String id;
  final String name;
  final String imageUrl;
  final String type;
  final String additionalInfo;
  final Map<String, dynamic> attributes;

  Favorite({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.type,
    required this.additionalInfo,
    required this.attributes,
  });
   factory Favorite.empty() {
    return Favorite(
      id: '',
      name: 'Unknown',
      imageUrl: '',
      type: '',
      additionalInfo: '',
      attributes: {},
    );
  }
}