import 'package:e7gezly/presentation/screens/football.dart';
import 'package:e7gezly/presentation/screens/padel.dart';
import 'package:e7gezly/presentation/screens/playstation.dart';
import 'package:flutter/material.dart';
import 'package:e7gezly/domain/entities/favorite.dart';
import 'package:e7gezly/presentation/widgets/place_card.dart';
import 'package:e7gezly/presentation/features/favorite/favorite_provider.dart';
import 'package:provider/provider.dart';

class FavoriteCard extends StatelessWidget {
  final Favorite favorite;

  const FavoriteCard({super.key, required this.favorite});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoritesProvider>(context, listen: false);

    return PlaceCard(
      id: favorite.id,
      name: favorite.name,
      imageUrl: favorite.imageUrl,
      additionalInfo: favorite.additionalInfo,
      attributes: favorite.attributes,
      type: favorite.type,
      isFavorite: true,
      onFavoriteToggle: () => provider.toggleFavorite(favorite, true),
      onTap: () => _navigateToDetails(context, favorite.type, favorite.id),
    );
  }

  void _navigateToDetails(BuildContext context, String type, String id) {
    switch (type) {
      case 'football':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AvailableHoursScreen(placeId: id)),
        );
        break;
      case 'playstation':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PlayStationRoomsScreen(playStationId: id)),
        );
        break;
      case 'padel':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PadelScreen(placeId: id)),
        );
        break;
    }
  }
}
