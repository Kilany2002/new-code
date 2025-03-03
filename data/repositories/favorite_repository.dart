import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/favorite.dart';

class FavoritesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Favorite>> fetchFavorites(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var data = doc.data();
              return Favorite(
                id: doc.id,
                name: data['name'] ?? 'Unknown',
                imageUrl: data['image'] ?? '',
                type: data['type'] ?? 'unknown',
                additionalInfo: data['additionalInfo'] ?? '',
                attributes: data,
              );
            }).toList());
  }

  Future<void> toggleFavorite(String userId, Favorite favorite, bool isFavorite) async {
    var favoritesRef = _firestore.collection('users').doc(userId).collection('favorites').doc(favorite.id);
    if (isFavorite) {
      await favoritesRef.delete();
    } else {
      await favoritesRef.set(favorite.attributes);
    }
  }
}