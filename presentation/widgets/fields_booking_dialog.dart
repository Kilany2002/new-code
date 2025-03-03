import 'package:e7gezly/presentation/widgets/fields_booking_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../paymob/views/payment_view.dart';

class FieldsBookingDialog extends StatefulWidget {
  final String hourLabel;
  final double price;
  final Map dayData;
  final int startHour;
  final String formattedDate;
  final String placeId; // Add placeId as a parameter

  const FieldsBookingDialog({
    Key? key,
    required this.hourLabel,
    required this.price,
    required this.dayData,
    required this.startHour,
    required this.formattedDate,
    required this.placeId, // Include placeId
  }) : super(key: key);

  @override
  _BookingDialogState createState() => _BookingDialogState();
}

class _BookingDialogState extends State<FieldsBookingDialog> {
  final BookingService _bookingService = BookingService(); // Initialize the service
  List<String> selectedHours = [];
  double totalBasePrice = 0.0;

  @override
  void initState() {
    super.initState();
    selectedHours.add(widget.hourLabel);
    totalBasePrice += widget.price;
  }

  void _updateTotalPrice() {
    setState(() {
      totalBasePrice = selectedHours.length * widget.price;
    });
  }

  void _addNextHour() {
    if (selectedHours.isNotEmpty) {
      String lastHour = selectedHours.last;
      int lastHourInt = int.parse(lastHour.split(':')[0]);
      bool isPm = lastHour.contains('PM');
      int nextHourInt = lastHourInt + 1;
      if (nextHourInt == 12) {
        isPm = !isPm;
      }
      if (nextHourInt > 12) {
        nextHourInt = nextHourInt - 12;
      }
      String nextHourLabel = _formatHourWithAmPm(nextHourInt, isPm);

      final nextHourData = widget.dayData[nextHourLabel] as Map? ?? {};
      final isNextHourBooked = nextHourData['isBooked'] ?? false;

      if (!isNextHourBooked) {
        setState(() {
          selectedHours.add(nextHourLabel);
          _updateTotalPrice();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('next_hour_booked'))),
        );
      }
    }
  }

  String _formatHourWithAmPm(int hour, bool isPm) {
    final period = isPm ? 'PM' : 'AM';
    final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$formattedHour:00 $period - ${formattedHour + 1}:00 $period';
  }

  @override
  Widget build(BuildContext context) {
    double bookingPrice = totalBasePrice * 0.25;
    double serviceFee = totalBasePrice * 0.05;
    double totalPrice = bookingPrice + serviceFee;

    return AlertDialog(
      backgroundColor: const Color(0xFFF4A81C),
      title: Text(tr('book_hour')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tr('selected_hours')),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: selectedHours.map((hour) => Text(hour)).toList(),
          ),
          const SizedBox(height: 10),
          const Divider(),
          Text('${tr('base_price')}: $totalBasePrice ${tr('currency')}'),
          const SizedBox(height: 10),
          Text(tr('total_booking')),
          const SizedBox(height: 10),
          Text('${tr('booking_price')}: $bookingPrice ${tr('currency')}'),
          Text('${tr('service_fee')}: $serviceFee ${tr('currency')}'),
          const SizedBox(height: 10),
          const Divider(),
          Text('${tr('total_price')}: $totalPrice ${tr('currency')}'),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _addNextHour,
              child: Text(tr('add_another_hour'), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(tr('cancel'), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentView(
                      price: totalPrice,
                      selectedHour: selectedHours.join(', '),
                      placeId: widget.placeId, 
                      formattedDate: widget.formattedDate,
                      userName: '',
                      email: '',
                      phoneNumber: '',
                      onPaymentSuccess: () async {
                        for (String hour in selectedHours) {
                          await _bookingService.updateBookingStatus(
                            hour,
                            widget.formattedDate,
                            widget.placeId, 
                            '', 
                            '', 
                            totalPrice,
                            widget.price,
                          );
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(tr('payment_success'))),
                        );
                        Navigator.pop(context);
                      },
                      onPaymentError: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(tr('payment_failed'))),
                        );
                      },
                    ),
                  ),
                );
              },
              child: Text(tr('confirm'), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }
}