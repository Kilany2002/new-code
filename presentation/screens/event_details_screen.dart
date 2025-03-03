import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e7gezly/paymobss/views/payment_view.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../classes/loading_indicator.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_scaffold.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/subscribe_to_event_use_case.dart';
import '../widgets/detail_row.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  EventDetailsScreen({required this.eventId});

  @override
  _EventDetailsScreenState createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final SubscribeToEventUseCase subscribeToEventUseCase =
      SubscribeToEventUseCase(
    EventRepositoryImpl(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    ),
  );

  EventEntity? event;
  bool isSubscribed = false;
  int remainingSpots = 0;

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
    checkSubscriptionStatus();
  }

  Future<void> fetchEventDetails() async {
    final eventDetails = await subscribeToEventUseCase.repository
        .getEventDetails(widget.eventId);
    final spots = await subscribeToEventUseCase.repository
        .getRemainingSpots(widget.eventId);
    setState(() {
      event = eventDetails;
      remainingSpots = spots;
    });
  }

  Future<void> checkSubscriptionStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final isSubscribed = await subscribeToEventUseCase.repository
          .isUserSubscribed(widget.eventId, user.uid);
      setState(() {
        this.isSubscribed = isSubscribed;
      });
    }
  }

  Future<void> handleSubscription() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await subscribeToEventUseCase.execute(widget.eventId, user.uid);
      setState(() {
        isSubscribed = true;
        remainingSpots--;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('You have successfully subscribed to this event!')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      return Center(child: LoadingIndicator());
    }

    return CustomScaffold(
      appBar: CustomAppBar(
        title: event!.gameName,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                event!.imageUrl,
                fit: BoxFit.cover,
                height: 300,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child:
                      Icon(Icons.broken_image, size: 100, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              event!.gameName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  DetailRow(label: tr('Console'), value: event!.conType),
                  DetailRow(label: tr('Place'), value: event!.place),
                  DetailRow(
                      label: tr('Subscribers'), value: '${event!.numSub}'),
                  DetailRow(
                      label: tr('Price'),
                      value: '\جنيه${event!.price.toString()}'),
                  DetailRow(
                      label: tr('Remaining Spots'), value: '$remainingSpots'),
                  DetailRow(
                    label: tr('Start Date'),
                    value: DateFormat('dd MMMM yyyy').format(event!.startDate),
                  ),
                  DetailRow(
                    label: tr('Start Time'),
                    value: DateFormat('HH:mm').format(event!.startDate),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  backgroundColor: isSubscribed ? Colors.orange : Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: isSubscribed
                    ? null 
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentView(
                              price: event!.price,
                              onPaymentSuccess: handleSubscription,
                              onPaymentError: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(tr('Payment failed')),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                child: Text(
                  isSubscribed ? tr('You are Subscribed') : tr('Subscribe'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSubscribed ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
