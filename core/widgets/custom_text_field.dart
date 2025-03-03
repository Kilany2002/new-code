import 'package:e7gezly/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData prefixIcon;

  const CustomTextField({
    Key? key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon = Icons.text_fields,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText != null ? tr(labelText!) : null,
        hintText: hintText != null ? tr(hintText!) : null,
        filled: true,
        fillColor: AppColors.whColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(prefixIcon, color: AppColors.prColor),
        labelStyle: const TextStyle(color: AppColors.blColor),
        hintStyle: const TextStyle(color: AppColors.blColor),
      ),
      style: const TextStyle(color: AppColors.blColor),
      obscureText: obscureText,
      keyboardType: keyboardType,
    );
  }
}
