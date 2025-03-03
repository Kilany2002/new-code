import 'package:e7gezly/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/entities/history.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.prColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.videogame_asset,
                    color: AppColors.blColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${tr('playstation_name')}: ${booking.playStationName}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.meeting_room,
                    color: AppColors.blColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${tr('room_name')}: ${booking.roomName}',
                      style: const TextStyle(
                          color: AppColors.blColor,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.gamepad, color: AppColors.blColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${tr('console_type')}: ${booking.currentMode}',
                      style: const TextStyle(
                          color: AppColors.blColor,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money,
                    color: AppColors.blColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${tr('total_cost')}: ${booking.totalCost.toStringAsFixed(2)} ${tr('currency')}',
                    style: const TextStyle(
                        color: AppColors.blColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer, color: AppColors.blColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${tr('total_time')}: ${booking.totalMinutes} ${tr('minutes')}',
                    style: const TextStyle(
                        color: AppColors.blColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (booking.orders.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr('orders'),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.blColor)),
                  const SizedBox(height: 4),
                  ...booking.orders.map((order) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${order['name']} x ${order['quantity']}',
                              style: const TextStyle(
                                  color: AppColors.blColor,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${order['price']} ${tr('currency')}',
                            style: const TextStyle(
                                color: AppColors.blColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
