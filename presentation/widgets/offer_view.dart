
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OfferView extends StatelessWidget {
  const OfferView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
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
    );
  }
}
