import 'package:e7gezly/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class PriceInfoDialog extends StatelessWidget {
  final Map<String, dynamic> attributes;

  const PriceInfoDialog({super.key, required this.attributes});

  List<Widget> _getPriceWidgets(Map<String, dynamic> attributes) {
    final List<Widget> priceWidgets = [];

    void addPrice(String key, String label, IconData icon) {
      if (attributes[key] != null) {
        priceWidgets.add(
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.whColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.blColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${tr(label)}: ${attributes[key]} ${tr('egp')}',
                    style:
                        const TextStyle(fontSize: 14, color: AppColors.blColor),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    addPrice('ps4_multi_private_room_price', 'ps4_multi_private',
        Icons.sports_esports);
    addPrice('ps4_multi_regular_room_price', 'ps4_multi_regular',
        Icons.sports_esports);
    addPrice('ps4_private_room_price', 'ps4_private', Icons.sports_esports);
    addPrice('ps4_regular_room_price', 'ps4_regular', Icons.sports_esports);
    addPrice('ps5_multi_private_room_price', 'ps5_multi_private',
        Icons.videogame_asset);
    addPrice('ps5_multi_regular_room_price', 'ps5_multi_regular',
        Icons.videogame_asset);
    addPrice('ps5_private_room_price', 'ps5_private', Icons.videogame_asset);
    addPrice('ps5_regular_room_price', 'ps5_regular', Icons.videogame_asset);

    return priceWidgets;
  }

  @override
  Widget build(BuildContext context) {
    final priceWidgets = _getPriceWidgets(attributes);

    return AlertDialog(
      backgroundColor: AppColors.prColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        tr('room_prices'),
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.blColor),
      ),
      content: priceWidgets.isEmpty
          ? Text(tr('no_prices_available'),
              style: const TextStyle(color: AppColors.whColor))
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: priceWidgets,
            ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(tr('close'),
              style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.whColor,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
