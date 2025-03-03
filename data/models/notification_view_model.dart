import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e7gezly/core/constants/colors.dart';
import 'package:flutter/material.dart';

class notificationViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _notifications = []; // Store notification data

  String userId = "No ID";

  void showNotifications(BuildContext context) {
    _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'read': true});
      }
    });

    // Show the notifications in a bottom sheet
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];

          // Display notifications here
          String iconName = notification['icon'] ?? 'notifications';
          DateTime notificationTime =
              (notification['timestamp'] as Timestamp).toDate();
          String timeElapsed = _calculateTimeElapsed(notificationTime);

          return Stack(
            children: [
              Card(
                color: const Color.fromARGB(191, 255, 153, 0),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: Icon(
                    _getIconForNotification(iconName),
                    color: AppColors.blColor,
                  ),
                  title: Text(
                    notification['title'] ?? 'No Title',
                    style: const TextStyle(
                        color: AppColors.blColor, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    notification['body'] ?? 'No Body',
                    style: const TextStyle(color: AppColors.blColor),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.blColor.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    timeElapsed,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _calculateTimeElapsed(DateTime notificationTime) {
    final now = DateTime.now();
    final difference = now.difference(notificationTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 7).floor()}w'; // Show weeks for older notifications
    }
  }

  IconData _getIconForNotification(String iconName) {
    switch (iconName) {
      case 'videogame_asset':
        return Icons.videogame_asset;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'sports_tennis':
        return Icons.sports_tennis;
      default:
        return Icons.notifications;
    }
  }
}
