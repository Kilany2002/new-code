import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';

class MobileWalletScreen extends StatefulWidget {
  final String redirectUrl;
  final VoidCallback onSuccess;
  final VoidCallback onError;
  final String placeId; // Add placeId parameter
  final String formattedDate; // Add formattedDate parameter
  final String selectedHour; // Add selectedHour parameter

  const MobileWalletScreen({
    super.key,
    required this.redirectUrl,
    required this.onSuccess,
    required this.onError,
    required this.placeId,
    required this.formattedDate,
    required this.selectedHour,
  });

  @override
  State<MobileWalletScreen> createState() => _MobileWalletScreenState();
}

class _MobileWalletScreenState extends State<MobileWalletScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setBackgroundColor(Color.fromARGB(255, 251, 251, 251))
              ..setNavigationDelegate(
                NavigationDelegate(
                  onNavigationRequest: (NavigationRequest request) async {
                    if (request.url.contains('success=true')) {
                      await _updateBookingStatus(widget.placeId,
                          widget.formattedDate, widget.selectedHour);
                      widget.onSuccess();
                    }
                    if (request.url.contains('success=false')) {
                      widget.onError();
                    }
                    return NavigationDecision.navigate;
                  },
                ),
              )
              ..addJavaScriptChannel(
                'Toaster',
                onMessageReceived: (JavaScriptMessage message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message.message)),
                  );
                },
              )
              ..loadRequest(Uri.parse(widget.redirectUrl))),
      ),
    );
  }

  Future<void> _updateBookingStatus(
      String placeId, String date, String hour) async {
    try {
      final DocumentReference documentRef =
          FirebaseFirestore.instance.collection('football_fields').doc(placeId);

      // Update the hour to be marked as booked
      await documentRef.update({
        'hours.$date.$hour.isBooked': true,
      });
      print("Hour successfully marked as booked in Firestore!");
    } catch (e) {
      print("Error updating booking status: $e");
    }
  }
}
