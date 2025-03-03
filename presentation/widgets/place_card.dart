import 'dart:io';
import 'package:flutter/material.dart';
import 'package:e7gezly/core/constants/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:e7gezly/presentation/widgets/price_info_dialog.dart';

class PlaceCard extends StatelessWidget {
  final String id;
  final String name;
  final String imageUrl;
  final String additionalInfo;
  final Map<String, dynamic> attributes;
  final String type;
  final bool isFavorite;
  final Function onFavoriteToggle;
  final Function onTap;

  const PlaceCard({
    Key? key,
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.additionalInfo,
    required this.attributes,
    required this.type,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.prColor,
      margin: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: _buildImage(imageUrl),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
            color: AppColors.blColor,
          ),
        ),
        subtitle: _buildSubtitle(),
        trailing: _buildTrailing(context),
        onTap: () => onTap(),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
        radius: 30,
      );
    } else if (File(imageUrl).existsSync()) {
      return CircleAvatar(
        backgroundImage: FileImage(File(imageUrl)),
        radius: 30,
      );
    } else {
      return const CircleAvatar(
        backgroundColor: AppColors.blueColor,
        radius: 30,
        child: Icon(Icons.image, color: AppColors.whColor),
      );
    }
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          additionalInfo,
          style: const TextStyle(color: AppColors.blColor, fontSize: 16),
        ),
        const SizedBox(height: 8),
        _buildIcons(),
      ],
    );
  }

  Widget _buildIcons() {
    return Row(
      children: [
        if (attributes['ps4_multi_private_room_price'] != null)
          const Text(
            'PS4',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.blColor,
              fontSize: 16,
            ),
          ),
        const SizedBox(width: 8),
        if (attributes['has_wifi'] == true)
          Tooltip(
            message: tr('wifi_available'),
            child: const Icon(
              Icons.wifi,
              color: AppColors.blueColor,
              size: 20,
            ),
          ),
        const SizedBox(width: 8),
        if (attributes['has_cafe'] == true)
          Tooltip(
            message: tr('cafe_available'),
            child: const Icon(
              Icons.local_cafe,
              color: AppColors.blueColor,
              size: 20,
            ),
          ),
        const SizedBox(width: 8),
        if (attributes['shows_matches'] == true)
          Tooltip(
            message: tr('shows_matches'),
            child: const Icon(
              Icons.tv_rounded,
              color: AppColors.blueColor,
              size: 20,
            ),
          ),
        const SizedBox(width: 8),
        if (attributes['ps5_multi_private_room_price'] != null)
          const Text(
            'PS5',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.blColor,
              fontSize: 16,
            ),
          ),
      ],
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.info, color: AppColors.blColor),
          onPressed: () => _showPriceInfoDialog(context),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            Icons.favorite,
            color: isFavorite ? AppColors.redColor : AppColors.whColor,
          ),
          onPressed: () => onFavoriteToggle(),
        ),
      ],
    );
  }

  void _showPriceInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return PriceInfoDialog(attributes: attributes);
      },
    );
  }
}
