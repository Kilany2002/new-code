import 'package:e7gezly/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/map.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_scaffold.dart';
import '../widgets/playstation_room_card.dart';

class PlayStationRoomsScreen extends StatefulWidget {
  final String playStationId;

  const PlayStationRoomsScreen({required this.playStationId});

  @override
  _PlayStationRoomsScreenState createState() => _PlayStationRoomsScreenState();
}

class _PlayStationRoomsScreenState extends State<PlayStationRoomsScreen> {
  DateTime selectedDate = DateTime.now();
  LatLng? playStationLocation;
  String? playStationImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchPlayStationDetails();
  }

  Future<void> _fetchPlayStationDetails() async {
    try {
      DocumentSnapshot playStationDoc = await FirebaseFirestore.instance
          .collection('play_stations')
          .doc(widget.playStationId)
          .get();

      if (playStationDoc.exists && playStationDoc.data() != null) {
        Map<String, dynamic> data =
            playStationDoc.data() as Map<String, dynamic>;

        GeoPoint? geoPoint = data['location'] as GeoPoint?;
        String? imageUrl = data['image'] as String?;

        setState(() {
          playStationLocation = LatLng(geoPoint!.latitude, geoPoint.longitude);
          playStationImageUrl = imageUrl;
        });
      }
    } catch (e) {
      print("Error fetching PlayStation details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        title: tr('playstation_rooms').tr(),
        showBackButton: true,
        actions: [
          if (playStationLocation != null)
            IconButton(
              icon: const Icon(Icons.map, color: AppColors.blColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MapScreen(initialLocation: playStationLocation!),
                  ),
                );
              },
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
                  '${tr('booking_date')}: ${selectedDate.toIso8601String().substring(0, 10)}',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 8)),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.prColor),
                  child: Text(tr('choose_date'),
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('play_stations')
                  .doc(widget.playStationId)
                  .collection('rooms')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rooms = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    final roomName = room['name'];
                    final roomId = room.id;
                    final roomData = room.data() as Map<String, dynamic>;
                    final roomImageUrl = roomData['image'] ?? '';
                    final airConditioned = roomData['airConditioned'] ?? false;
                    final bluetooth = roomData['bluetooth'] ?? false;
                    bool isVIP = roomData['isVIP'] ?? false;
                    bool ps4Available = roomData['ps4Available'] ?? false;
                    bool ps5Available = roomData['ps5Available'] ?? false;
                    return RoomCard(
                      roomId: roomId,
                      roomName: roomName,
                      roomImageUrl: roomImageUrl,
                      isVIP: isVIP,
                      bluetooth: bluetooth,
                      airConditioned: airConditioned,
                      ps4Available: ps4Available,
                      ps5Available: ps5Available,
                      selectedDate: selectedDate,
                      playStationId: widget.playStationId,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
