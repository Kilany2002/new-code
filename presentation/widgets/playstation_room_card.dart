import 'package:e7gezly/core/constants/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e7gezly/presentation/widgets/playstation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/usecases/fetch_playstation_details_usecase.dart';

class RoomCard extends StatelessWidget {
  final String roomId;
  final String roomName;
  final String? roomImageUrl;
  final bool isVIP;
  final bool ps4Available;
  final bool ps5Available;
  final bool airConditioned;
  final bool bluetooth;
  final DateTime selectedDate;
  final String playStationId;
  final BookingUseCase _useCase = BookingUseCase();

  RoomCard({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.roomImageUrl,
    required this.isVIP,
    required this.ps4Available,
    required this.ps5Available,
    required this.bluetooth,
    required this.airConditioned,
    required this.selectedDate,
    required this.playStationId,
  });

  void _showImageFullScreen(BuildContext context, String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Image.network(imageUrl)),
        ),
      ),
    );
  }

  Widget _buildRoomImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Icon(Icons.image, size: 50, color: Colors.grey);
    } else {
      return Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.prColor,
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15.0),
        leading: roomImageUrl != null && roomImageUrl!.isNotEmpty
            ? GestureDetector(
                onTap: () => _showImageFullScreen(context, roomImageUrl),
                child: _buildRoomImage(roomImageUrl),
              )
            : const Icon(Icons.image, size: 50),
        title: Text(
          roomName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('play_stations')
                  .doc(playStationId)
                  .collection('rooms')
                  .doc(roomId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> roomSnapshot) {
                if (!roomSnapshot.hasData) {
                  return const Text('Loading...');
                }
                bool isCurrentlyBooked =
                    roomSnapshot.data!['isBooked'] ?? false;
                bool isCurrentDay = selectedDate.day == DateTime.now().day &&
                    selectedDate.month == DateTime.now().month &&
                    selectedDate.year == DateTime.now().year;

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('play_stations')
                      .doc(playStationId)
                      .collection('rooms')
                      .doc(roomId)
                      .collection('upcoming_bookings')
                      .where('startDate', isGreaterThanOrEqualTo: selectedDate)
                      .where('startDate',
                          isLessThan: selectedDate.add(const Duration(days: 1)))
                      .snapshots(),
                  builder:
                      (context, AsyncSnapshot<QuerySnapshot> bookingSnapshot) {
                    if (!bookingSnapshot.hasData) {
                      return const Text('Loading...');
                    }

                    final bookings = bookingSnapshot.data!.docs;
                    bool isBooked = (isCurrentDay && isCurrentlyBooked) ||
                        bookings.isNotEmpty;

                    String bookingTimes = bookings.isNotEmpty
                        ? bookings
                            .map((booking) => formatTimeWithArabicAmPm(
                                (booking['startDate'] as Timestamp).toDate()))
                            .join(', ')
                        : '';
                    return Text(
                      isBooked
                          ? isCurrentlyBooked
                              ? '${tr('currently_booked')} ${bookingTimes.isNotEmpty ? ' ${tr('and_at')}: $bookingTimes' : ''}'
                              : '${tr('booked_at')}: $bookingTimes'
                          : tr('available'),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (isVIP)
                    const Text(
                      'VIP',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  if (airConditioned)
                    const Icon(Icons.ac_unit, color: Colors.lightBlue),
                  if (ps4Available)
                    const Text(
                      'PS4',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  if (bluetooth)
                    const Icon(Icons.bluetooth,
                        color: Color.fromARGB(255, 7, 50, 124)),
                  if (ps5Available)
                    const Text(
                      'PS5',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => BookingDialog(
                roomId: roomId,
                roomName: roomName,
                ps4Available: ps4Available,
                ps5Available: ps5Available,
                selectedDate: selectedDate,
                playStationId: playStationId,
                useCase: _useCase,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blColor,
          ),
          child: Text(
            tr('request_booking'),
            style: const TextStyle(
                color: AppColors.whColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  String formatTimeWithArabicAmPm(DateTime dateTime) {
    final DateFormat formatter = DateFormat('hh:mm a');
    String formattedTime = formatter.format(dateTime);

    return formattedTime.replaceAll('AM', 'صباحاً').replaceAll('PM', 'مساءً');
  }
}
