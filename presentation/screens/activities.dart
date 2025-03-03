import 'package:e7gezly/core/widgets/custom_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e7gezly/presentation/screens/football.dart';
import 'package:e7gezly/presentation/screens/playstation.dart';
import 'package:e7gezly/presentation/screens/padel.dart';
import 'package:e7gezly/presentation/widgets/place_card.dart';
import 'package:e7gezly/core/constants/colors.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/widgets/custom_app_bar.dart';

class AvailablePlacesScreen extends StatelessWidget {
  final String type;
  final String userId;

  const AvailablePlacesScreen({
    super.key,
    required this.type,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        title: tr(type),
        showBackButton: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(_getCollectionName(type))
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final places = snapshot.data!.docs;

          if (places.isEmpty) {
            return Center(
              child: Text(
                tr("no_places"),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grColor),
              ),
            );
          }

          return ListView.builder(
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              final placeData = place.data() as Map<String, dynamic>? ?? {};
              final name = placeData['name'] ?? 'Unknown';
              final additionalInfo = _getAdditionalInfo(placeData, type);
              final imageUrl = placeData['image'] ?? '';

              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('favorites')
                    .doc(place.id)
                    .snapshots(),
                builder:
                    (context, AsyncSnapshot<DocumentSnapshot> favSnapshot) {
                  final isFavorite =
                      favSnapshot.hasData && favSnapshot.data!.exists;

                  return PlaceCard(
                    id: place.id,
                    name: name,
                    imageUrl: imageUrl,
                    additionalInfo: additionalInfo,
                    attributes: placeData,
                    type: type,
                    isFavorite: isFavorite,
                    onFavoriteToggle: () async {
                      final userFavorites = FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('favorites');

                      if (isFavorite) {
                        await userFavorites.doc(place.id).delete();
                      } else {
                        await userFavorites.doc(place.id).set({
                          'name': name,
                          'image': imageUrl,
                          'type': type,
                          'additionalInfo': additionalInfo,
                          'has_wifi': placeData['has_wifi'] ?? false,
                          'has_cafe': placeData['has_cafe'] ?? false,
                          'shows_matches': placeData['shows_matches'] ?? false,
                          'morsak': placeData['morsak'] ?? false,
                          'ps4_multi_private_room_price':
                              placeData['ps4_multi_private_room_price'],
                          'ps4_multi_regular_room_price':
                              placeData['ps4_multi_regular_room_price'],
                          'ps4_private_room_price':
                              placeData['ps4_private_room_price'],
                          'ps4_regular_room_price':
                              placeData['ps4_regular_room_price'],
                          'ps5_multi_private_room_price':
                              placeData['ps5_multi_private_room_price'],
                          'ps5_multi_regular_room_price':
                              placeData['ps5_multi_regular_room_price'],
                          'ps5_private_room_price':
                              placeData['ps5_private_room_price'],
                          'ps5_regular_room_price':
                              placeData['ps5_regular_room_price'],
                        });
                      }
                    },
                    onTap: () => _navigateToDetails(context, place.id, type),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _getCollectionName(String type) {
    switch (type) {
      case 'football':
        return 'football_fields';
      case 'playstation':
        return 'play_stations';
      case 'padel':
        return 'padel';
      default:
        return 'places';
    }
  }

  String _getAdditionalInfo(Map<String, dynamic> data, String type) {
    if (type == 'football') {
      return '${tr("morning_price")}: ${data['morning_price'] ?? 'N/A'} EGP\n'
          '${tr("evening_price")}: ${data['evening_price'] ?? 'N/A'} EGP';
    } else if (type == 'playstation') {
      return '${tr("rooms")}: ${data['room_count'] ?? 'N/A'}\n'
          '${tr("morsak")}: ${data['morsak'] ?? 'N/A'}';
    } else if (type == 'padel') {
      return '${tr("morning_price")}: ${data['morning_price'] ?? 'N/A'} EGP\n'
          '${tr("evening_price")}: ${data['evening_price'] ?? 'N/A'} EGP';
    }
    return 'No additional info';
  }

  void _navigateToDetails(BuildContext context, String id, String type) {
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
