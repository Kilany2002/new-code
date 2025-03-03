import 'package:e7gezly/classes/loading_indicator.dart';
import 'package:e7gezly/core/constants/colors.dart';
import 'package:e7gezly/core/widgets/custom_scaffold.dart';
import 'package:e7gezly/presentation/features/user%20bookings/booking_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../widgets/booking_card.dart';

class UserBookingsScreen extends StatelessWidget {
  final String userId;

  const UserBookingsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserBookingsProvider(userId)..fetchUserBookings(),
      child: Consumer<UserBookingsProvider>(
        builder: (context, provider, child) {
          return CustomScaffold(
            appBar: CustomAppBar(
        title: tr('current_bookings'),
        showBackButton: true,
      ),
            body: Container(
              child: provider.isLoading
                  ? LoadingIndicator()
                  : RefreshIndicator(
                      onRefresh: provider.fetchUserBookings,
                      child: provider.bookings.isEmpty
                          ? Center(
                              child: Text(tr('no_current_bookings'),
                                  style: const TextStyle(
                                      fontSize: 18, color: AppColors.grColor)),
                            )
                          : ListView.builder(
                              itemCount: provider.bookings.length,
                              itemBuilder: (context, index) {
                                return BookingCard(
                                    booking: provider.bookings[index]);
                              },
                            ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
