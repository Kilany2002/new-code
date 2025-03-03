// presentation/screens/home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e7gezly/data/models/home_view_model.dart';
import 'package:e7gezly/data/models/image_veiw_model.dart';
import 'package:e7gezly/data/models/menu_view_model.dart';
import 'package:e7gezly/data/models/notification_view_model.dart';
import 'package:e7gezly/domain/usecases/get_notifications.dart';
import 'package:e7gezly/domain/usecases/get_user.dart';
import 'package:e7gezly/presentation/widgets/competitions_view.dart';
import 'package:e7gezly/presentation/widgets/home_soon.dart';
import 'package:e7gezly/presentation/widgets/offer_view.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e7gezly/core/widgets/custom_scaffold.dart';
import 'package:e7gezly/presentation/widgets/bottom_nav_bar.dart';
import 'package:e7gezly/presentation/widgets/home_app_bar.dart';
import 'package:e7gezly/data/repositories/user_repository_impl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final firestore = FirebaseFirestore.instance;
        final storage = FirebaseStorage.instance;
        final userRepo = UserRepositoryImpl(firestore, storage);
        final getUserData = GetUserData(userRepo);
        final getNotifications = GetNotifications(userRepo);
        return HomeViewModel(getUserData, getNotifications)..loadData();
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
        bottomNavigationBar: const CustomBottomNavigationBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);
    return CustomHomeAppBar(
      userName: viewModel.user?.name ?? "Guest",
      userImageUrl: viewModel.user?.imageUrl,
      notificationCount: viewModel.notifications
          .where((notification) => !notification.read)
          .length,
      onImageTap: () {
        context.read<ImageViewModel>().showImageOptions(context);
      },
      onNotificationsTap: () {
        context.read<notificationViewModel>().showNotifications(context);
      },
      onMenuTap: () {
        context.read<MenuViewModel>().showUserMenu(context);
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context);

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return const CustomScaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    CompetitionsView(),
                    homeSoon(),
                    SizedBox(height: 20),
                    OfferView(),
                    homeSoon(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
