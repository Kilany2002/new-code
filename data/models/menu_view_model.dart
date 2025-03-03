import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e7gezly/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

class MenuViewModel with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double userPoints = 0.0;
  void listenToUserPoints() {
    var user = _auth.currentUser;
    if (user != null) {
      _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          // Convert points to double to avoid type mismatch
          userPoints = (snapshot['points'] ?? 0).toDouble();
          print('Updated user points: $userPoints'); // Log the updated points
        } else {
          print('Snapshot does not exist for user or widget is not mounted');
        }
      });
    } else {
      print('User is null, cannot listen to points');
    }
  }

  void showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: AppColors.prColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.blColor),
              title: Text(
                tr('settings'),
                style: const TextStyle(color: AppColors.blColor),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: AppColors.blColor),
              title: Text(
                '${tr('points')}: $userPoints',
                style: const TextStyle(color: AppColors.blColor),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language, color: AppColors.blColor),
              title: Text(
                tr('switch_language'),
                style: const TextStyle(color: AppColors.blColor),
              ),
              onTap: () {
                Navigator.pop(context);
                switchLanguage(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: AppColors.blColor),
              title: Text(
                tr('logout'),
                style: const TextStyle(color: AppColors.blColor),
              ),
              onTap: () {
                Navigator.pop(context);
                logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void switchLanguage(BuildContext context) {
    if (context.locale == const Locale('en')) {
      context.setLocale(const Locale('ar'));
    } else {
      context.setLocale(const Locale('en'));
    }
  }

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  void notificationViewModel(BuildContext context) {}
}
