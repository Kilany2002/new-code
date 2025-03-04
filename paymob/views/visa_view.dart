import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VisaScreen extends StatefulWidget {
  const VisaScreen({
    super.key,
    required this.finalToken,
    required this.iframeId,
    required this.onFinished,
    required this.onError,
    required this.placeId,
    required this.formattedDate,
    required this.selectedHour,
  });

  final String finalToken;
  final String iframeId;
  final VoidCallback onFinished;
  final VoidCallback onError;
  final String placeId; // Add placeId parameter
  final String formattedDate; // Add formattedDate parameter
  final String selectedHour; // Add selectedHour parameter

  @override
  State<VisaScreen> createState() => _VisaScreenState();
}

class _VisaScreenState extends State<VisaScreen> {
  bool _isPaymentCompleted = false; // A flag to prevent duplicate notifications

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(Color.fromARGB(250, 255, 252, 252))
            ..setNavigationDelegate(
              NavigationDelegate(
                onNavigationRequest: (NavigationRequest request) {
                  return NavigationDecision.navigate;
                },
                onPageFinished: (url) async {
                  // Prevent further execution if payment is already completed
                  if (_isPaymentCompleted) return;

                  // Check if the URL contains success and trigger the logic only once
                  if (!url.contains('iframes') &&
                      url.contains('success=true')) {
                    _isPaymentCompleted =
                        true; // Set the flag to true to prevent duplicate logic

                    // Call your booking update method
                    await _updateBookingStatus(widget.placeId,
                        widget.formattedDate, widget.selectedHour);

                    // Notify the parent widget of success
                    widget.onFinished();
                  }

                  // Handle the failure scenario
                  if (url.contains("success=false")) {
                    widget.onError();
                  }
                },
              ),
            )
            ..loadRequest(Uri.parse(
                "https://accept.paymob.com/api/acceptance/iframes/${widget.iframeId}?payment_token=${widget.finalToken}")),
        ),
      ),
    );
  }

  // Method to update booking status in Firestore
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
