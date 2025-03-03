import 'package:e7gezly/core/constants/colors.dart';
import 'package:e7gezly/presentation/screens/history_booking_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/favorite_screen.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;
  User? user;
  String userId = "No ID";

  void _showUserBookings() {
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              UserBookingsScreen(userId: user!.uid), // Pass the user's ID here
        ),
      );
    } else {
      // Handle the case where user is null, maybe show an error or a login screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Add your navigation logic here
    switch (index) {
      case 0:
        // Navigate to Home Screen
        break;
      case 1:
        _showUserBookings();
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FavoritesScreen(userId: user?.uid ?? 'No ID'),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      unselectedItemColor: Colors.grey,
      selectedItemColor: AppColors.blColor,
      backgroundColor: AppColors.prColor,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: tr('home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.book),
          label: tr('my_bookings'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.favorite),
          label: tr('favorites'),
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }
}
