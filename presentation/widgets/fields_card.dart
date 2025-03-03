import 'package:e7gezly/core/constants/colors.dart';
import 'package:e7gezly/presentation/widgets/fields_booking_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HourCard extends StatelessWidget {
  final String title;
  final Map dayData;
  final int startHour;
  final int endHour;
  final double price;
  final String formattedDate;
  final String placeId; 

  const HourCard({
    Key? key,
    required this.title,
    required this.dayData,
    required this.startHour,
    required this.endHour,
    required this.price,
    required this.formattedDate,
    required this.placeId, // Include placeId in the constructor
  }) : super(key: key);

  String _formatHour(int hour) {
    final adjustedHour = hour % 24;
    final period = adjustedHour < 12 ? 'AM' : 'PM';
    final formattedHour = adjustedHour == 0
        ? 12
        : (adjustedHour > 12 ? adjustedHour - 12 : adjustedHour);
    return '$formattedHour:00 $period - ${(formattedHour % 12) + 1}:00 $period';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.prColor,
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: ExpansionTile(
        title: Text(
          '$title - ${tr('price')}: $price ${tr('currency')}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        children: List.generate(endHour - startHour, (index) {
          final hour = index + startHour;
          final hourLabel = _formatHour(hour);
          final hourData = dayData[hourLabel] as Map? ?? {};
          final isBooked = hourData['isBooked'] ?? false;

          return ListTile(
            title: Text(hourLabel, style: const TextStyle(color: Colors.black)),
            subtitle: Text(
              isBooked ? tr('booked') : tr('available'),
              style: TextStyle(
                color: isBooked ? Colors.red : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: isBooked
                ? null
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => FieldsBookingDialog(
                          hourLabel: hourLabel,
                          price: price,
                          dayData: dayData,
                          startHour: startHour,
                          formattedDate: formattedDate,
                          placeId: placeId, // Pass placeId here
                        ),
                      );
                    },
                    child: Text(tr('book'), style: const TextStyle(color: Color(0xFFF4A81C))),
                  ),
          );
        }),
      ),
    );
  }
}