import 'package:flutter/material.dart';

class Style {
  final Color? primaryColor,
      appBarBackgroundColor,
      appBarForegroundColor,
      unselectedColor,
      scaffoldColor,
      circleProgressColor;
  final TextStyle? textStyle;
  ButtonStyle? buttonStyle;
  final bool? showMobileWalletIcons;

  Style({
    this.circleProgressColor = const Color(0xFFF4A81C), // Set to orange
    this.primaryColor = const Color(0xFFF4A81C), // Set to orange
    this.appBarBackgroundColor = const Color(0xFFF4A81C), // Set to orange
    this.appBarForegroundColor = Colors.black,
    this.unselectedColor = Colors.grey,
    this.scaffoldColor = Colors.white,
    this.textStyle,
    this.buttonStyle,
    this.showMobileWalletIcons = true,
  }) {
    buttonStyle = buttonStyle ??
        ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10), // Prevent constant expression error
          ),
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
        );
  }
}
