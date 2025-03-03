import 'package:e7gezly/core/constants/colors.dart';
import 'package:e7gezly/presentation/widgets/favorite_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_scaffold.dart';
import '../features/favorite/favorite_provider.dart';

class FavoritesScreen extends StatelessWidget {
  final String userId;

  const FavoritesScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavoritesProvider(userId),
      child: Consumer<FavoritesProvider>(
        builder: (context, provider, child) {
          return CustomScaffold(
            appBar: CustomAppBar(
        title: tr('favorites'),
        showBackButton: true,
      ),
            body: Container(
              child: provider.favorites.isEmpty
                  ? Center(
                      child: Text(tr('no_favorites'),
                          style: const TextStyle(
                              color: AppColors.grColor, fontSize: 18)))
                  : ListView.builder(
                      itemCount: provider.favorites.length,
                      itemBuilder: (context, index) {
                        return FavoriteCard(
                            favorite: provider.favorites[index]);
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}
