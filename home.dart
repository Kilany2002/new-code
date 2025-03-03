import 'dart:io';
import 'package:e7gezly/core/constants/colors.dart';
import 'package:e7gezly/core/widgets/custom_scaffold.dart';
import 'package:e7gezly/presentation/screens/activities.dart';
import 'package:e7gezly/presentation/screens/event_details_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:e7gezly/presentation/screens/history_booking_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'presentation/screens/favorite_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  User? user;
  String userName = "No Name";
  String userEmail = "No Email";
  String userId = "No ID";
  String? userImageUrl;
  double userPoints = 0.0;
  int _notificationCount = 0;
  int _selectedIndex = 0; // Track the currently selected index

  List<Map<String, dynamic>> _notifications = []; // Store notification data

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadUser();
    _loadUserImage();
    _setupFirebaseMessaging();
    _listenToUnreadNotifications();
    _listenToUserPoints();
  }

  Future<void> _loadUserImage() async {
    user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user!.uid).get();
      if (userDoc.exists && mounted) {
        // Check if widget is still mounted
        final userData =
            userDoc.data() as Map<String, dynamic>?; // Cast the data to Map
        setState(() {
          // Check if userData is not null and contains 'image_url'
          userImageUrl = userData != null && userData.containsKey('image_url')
              ? userData['image_url']
              : null;
        });
      }
    }
  }

  void _listenToUserPoints() {
    user = _auth.currentUser;
    if (user != null) {
      _firestore
          .collection('users')
          .doc(user!.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && mounted) {
          setState(() {
            // Convert points to double to avoid type mismatch
            userPoints = (snapshot['points'] ?? 0).toDouble();
            print('Updated user points: $userPoints'); // Log the updated points
          });
        } else {
          print('Snapshot does not exist for user or widget is not mounted');
        }
      });
    } else {
      print('User is null, cannot listen to points');
    }
  }

  Future<void> _loadUser() async {
    user = _auth.currentUser;
    if (user != null) {
      userEmail = user!.email!;
      userId = user!.uid;
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user!.uid).get();
      if (userDoc.exists && mounted) {
        // Check if widget is still mounted
        setState(() {
          userName = userDoc['firstName'] ?? "No Name";
        });
        _firestore
            .collection('users')
            .doc(user!.uid)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          if (mounted) {
            // Check if widget is still mounted
            setState(() {
              _notificationCount = snapshot.docs.length;
              _notifications = snapshot.docs.map((doc) => doc.data()).toList();
            });
          }
        });
      }
    }
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        const InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _setupFirebaseMessaging() {
    FirebaseMessaging.instance.getToken().then((token) {
      _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        setState(() {
          _notificationCount++;
        });
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              '@mipmap/ic_launcher',
              'your_channel_name',
              importance: Importance.max,
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Navigator.pushNamed(context, '/');
    });
  }

  void _listenToUnreadNotifications() {
    if (userId.isNotEmpty) {
      _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _notificationCount = snapshot.docs.length; // Update count of unread
          _notifications = snapshot.docs.map((doc) => doc.data()).toList();
        });
      });
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

  void _showNotifications() {
    setState(() {
      _notificationCount = 0;
    });

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

    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
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
                    color: Colors.black,
                  ),
                  title: Text(
                    notification['title'] ?? 'No Title',
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    notification['body'] ?? 'No Body',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
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
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text(tr('show_image')), // Localized text
            onTap: () {
              Navigator.pop(context);
              if (userImageUrl != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(),
                      body: Center(
                        child: Image.network(userImageUrl!),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: Text(tr('choose_image')), // Localized text
            onTap: () {
              Navigator.pop(context);
              _pickImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: Text(tr('delete_image')), // Localized text
            onTap: () {
              Navigator.pop(context);
              _deleteImage();
            },
          ),
        ],
      ),
    );
  }
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String fileName = '${user!.uid}_profile.jpg';
      try {
        await _storage.ref('user_images/$fileName').putFile(imageFile);
        String imageUrl =
            await _storage.ref('user_images/$fileName').getDownloadURL();
        await _firestore
            .collection('users')
            .doc(user!.uid)
            .update({'image_url': imageUrl});
        setState(() {
          userImageUrl = imageUrl;
        });
      } catch (e) {
        print(e);
      }
    }
  }
  Future<void> _deleteImage() async {
    if (userImageUrl != null) {
      String fileName = '${user!.uid}_profile.jpg';
      try {
        await _storage.ref('user_images/$fileName').delete();
        await _firestore
            .collection('users')
            .doc(user!.uid)
            .update({'image_url': FieldValue.delete()});
        setState(() {
          userImageUrl = null;
        });
      } catch (e) {
        print(e);
      }
    }
  }
  void _showAvailablePlaces(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvailablePlacesScreen(
          type: type,
          userId: user!.uid,
        ),
      ),
    );
  }
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
  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }
  Widget _buildUpcomingEvents() {
    return StreamBuilder(
      stream: _firestore.collection('events').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final events = snapshot.data!.docs;
        if (events.isEmpty) {
          return const Center(
              child: Text('Coming Soon')); // Display message if no events
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: events.length,
          itemBuilder: (context, index) {
            var event = events[index];
            return ListTile(
              title: Text(event['title']),
              subtitle: Text(event['date']),
            );
          },
        );
      },
    );
  }
  void _switchLanguage() {
    if (context.locale == const Locale('en')) {
      context.setLocale(const Locale('ar'));
    } else {
      context.setLocale(const Locale('en'));
    }
  }
  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: const Color(0xFFF4A81C), // Background color for the menu
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.black),
              title: Text(
                tr('settings'),
                style: const TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.star, color: Colors.black),
              title: Text(
                '${tr('points')}: $userPoints',
                style: const TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.black),
              title: Text(
                tr('switch_language'),
                style: const TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                _switchLanguage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.black),
              title: Text(
                tr('logout'),
                style: const TextStyle(color: Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
  void _onBottomNavigationBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
    } else if (index == 1) {
      _showUserBookings();
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FavoritesScreen(userId: user!.uid),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.prColor,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showImageOptions,
                    child: CircleAvatar(
                      backgroundImage: userImageUrl != null
                          ? NetworkImage(userImageUrl!)
                          : null,
                      child: userImageUrl == null
                          ? Text(userName.substring(0, 1).toUpperCase())
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr('hello_user'),
                          style: const TextStyle(fontSize: 13)),
                      Text(userName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: _showNotifications,
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _showUserMenu,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAvailablePlaces('football'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: const Color(0xFFF4A81C),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.black),
                      ),
                    ),
                    icon: const Icon(Icons.sports_soccer),
                    label: Text(tr('football_fields')),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAvailablePlaces('playstation'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: const Color(0xFFF4A81C),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.black),
                      ),
                    ),
                    icon: const Icon(Icons.videogame_asset),
                    label: Text(tr('playstation')),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _showAvailablePlaces('padel'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color(0xFFF4A81C),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.black),
                  ),
                ),
                icon: const Icon(Icons.sports_tennis),
                label: Text(tr('padel')),
              ),
              const SizedBox(height: 40),
              Align(
                alignment: context.locale.languageCode == 'ar'
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  tr('competitions'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 250, 
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('events').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var events = snapshot.data!.docs;
                    if (events.isEmpty) {
                      return Center(
                        child: Text(
                          tr('soon'),
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ); 
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        var eventDoc = events[index];
                        var eventData = eventDoc.data() as Map<String, dynamic>;
                        var eventId = eventDoc.id;

                        String imageUrl = eventData.containsKey('image')
                            ? eventData['image']
                            : '';
                        String gameName = eventData.containsKey('game_name')
                            ? eventData['game_name']
                            : 'Unknown Game';
                        int numSub = eventData.containsKey('num_sub')
                            ? eventData['num_sub']
                            : 0;
                        String place = eventData.containsKey('place')
                            ? eventData['place']
                            : 'Unknown Place';

                        // Check if start_date exists and is a Timestamp, then format it
                        String startDate = '';
                        if (eventData.containsKey('start_date') &&
                            eventData['start_date'] is Timestamp) {
                          DateTime date =
                              (eventData['start_date'] as Timestamp).toDate();
                          startDate = DateFormat('dd MMM yyyy')
                              .format(date); // Format date as needed
                        }

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventDetailsScreen(
                                  eventId: eventId,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: AppColors.prColor,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              width: 160, // Adjust width as needed
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      height:
                                          120, // Adjust image height as needed
                                      width: double.infinity,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Center(
                                        child: Icon(Icons.broken_image,
                                            size: 50, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    gameName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text("${'place'.tr()}: $place"),
                                  Text("${'subs'.tr()}: $numSub"),
                                  Text(
                                      "${'start_date'.tr()}: $startDate"), // Display start date
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              Align(
                alignment: context.locale.languageCode == 'ar'
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(
                  tr('offers'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    tr('soon'),
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomNavigationBar(
            backgroundColor: const Color(0xFFF4A81C),
            items: [
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
            currentIndex: _selectedIndex, // Add logic to track selected index
            onTap: (index) {
              if (index == 0) {
              } else if (index == 1) {
                _showUserBookings();
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FavoritesScreen(userId: user!.uid),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
