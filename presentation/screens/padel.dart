import 'package:e7gezly/core/constants/colors.dart';
import 'package:e7gezly/core/constants/map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_scaffold.dart';
import '../widgets/fields_card.dart';

class PadelScreen extends StatefulWidget {
  final String placeId;

  const PadelScreen({required this.placeId, Key? key}) : super(key: key);

  @override
  _PadelScreenState createState() => _PadelScreenState();
}

class _PadelScreenState extends State<PadelScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _navigateToMap() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('padel')
          .doc(widget.placeId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final GeoPoint location = data['location'] as GeoPoint;
        final double latitude = location.latitude;
        final double longitude = location.longitude;

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapScreen(
                initialLocation: LatLng(latitude, longitude),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('error_fetching_location'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return CustomScaffold(
      appBar: CustomAppBar(
        title: tr('available_hours'),
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: Colors.black),
            onPressed: () => _navigateToMap(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${tr('booking_date')}: $formattedDate',
                  style:
                      const TextStyle(fontSize: 18, color: AppColors.whColor),
                ),
                ElevatedButton(
                  onPressed: () => _pickDate(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.prColor,
                  ),
                  child: Row(
                    children: [
                      
                      Text(tr('choose_date'),
                          style: const TextStyle(color: AppColors.blColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('padel')
                  .doc(widget.placeId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final hours = data['hours'] as Map<String, dynamic>? ?? {};
                final dayData =
                    hours[formattedDate] as Map<String, dynamic>? ?? {};
                final double morningPrice =
                    (data['morning_price'] as num?)?.toDouble() ?? 0.0;
                final double eveningPrice =
                    (data['evening_price'] as num?)?.toDouble() ?? 0.0;

                return ListView(
                  padding: const EdgeInsets.all(10.0),
                  children: [
                    HourCard(
                      title: tr('morning_hours'),
                      dayData: dayData,
                      startHour: 6,
                      endHour: 18,
                      price: morningPrice,
                      formattedDate: formattedDate,
                      placeId: widget.placeId,
                    ),
                    const SizedBox(height: 10),
                    HourCard(
                      title: tr('evening_hours'),
                      dayData: dayData,
                      startHour: 18,
                      endHour: 30,
                      price: eveningPrice,
                      formattedDate: formattedDate,
                      placeId: widget.placeId,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
