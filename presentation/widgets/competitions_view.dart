import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CompetitionsView extends StatelessWidget {
  const CompetitionsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: context.locale.languageCode == 'ar'
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Text(
        tr('competitions'),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
