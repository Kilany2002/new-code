import 'package:flutter/material.dart';
import '../../../data/repositories/favorite_repository.dart';
import '../../../domain/entities/favorite.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesRepository _repository = FavoritesRepository();
  final String userId;
  List<Favorite> _favorites = [];

  FavoritesProvider(this.userId) {
    _repository.fetchFavorites(userId).listen((favorites) {
      _favorites = favorites;
      notifyListeners();
    });
  }

  List<Favorite> get favorites => _favorites;

  Future<void> toggleFavorite(Favorite favorite, bool isFavorite) async {
    await _repository.toggleFavorite(userId, favorite, isFavorite);
  }
}
