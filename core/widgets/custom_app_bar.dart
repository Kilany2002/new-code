import 'package:e7gezly/core/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions; // Optional actions

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = false,
    this.actions, // Accepting actions as a parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title,
          style: const TextStyle(
              color: AppColors.blColor, fontWeight: FontWeight.bold)),
      backgroundColor: AppColors.prColor,
      centerTitle: true,
      automaticallyImplyLeading: showBackButton,
      actions: actions, // Adding the optional actions
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
