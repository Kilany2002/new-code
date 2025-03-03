// presentation/widgets/home_app_bar.dart
import 'package:e7gezly/core/constants/colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String? userImageUrl;
  final int notificationCount;
  final VoidCallback onImageTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onMenuTap;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const CustomHomeAppBar({
    Key? key,
    required this.userName,
    this.userImageUrl,
    required this.notificationCount,
    required this.onImageTap,
    required this.onNotificationsTap,
    required this.onMenuTap,
    this.backgroundColor = AppColors.prColor,
    this.iconColor = AppColors.blColor,
    this.textColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onImageTap,
            child: Row(
              children: [
                _buildUserAvatar(),
                const SizedBox(width: 8),
                _buildUserGreeting(),
              ],
            ),
          ),
        ],
      ),
      actions: [
        _buildNotificationIcon(),
        _buildMenuIcon(),
      ],
    );
  }

  Widget _buildUserAvatar() {
    return CircleAvatar(
      backgroundColor: AppColors.whColor,
      backgroundImage: userImageUrl != null ? NetworkImage(userImageUrl!) : null,
      child: userImageUrl == null
          ? Text(
              userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : '',
              style: TextStyle(color: textColor),
            )
          : null,
    );
  }

  Widget _buildUserGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('hello_user'),
          style: TextStyle(fontSize: 13, color: textColor),
        ),
        Text(
          userName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications, color: iconColor),
          onPressed: onNotificationsTap,
          tooltip: tr('notifications'), // Accessibility
        ),
        if (notificationCount > 0)
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
              child: Text(
                notificationCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMenuIcon() {
    return IconButton(
      icon: Icon(Icons.menu, color: iconColor),
      onPressed: onMenuTap,
      tooltip: tr('menu'), // Accessibility
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}