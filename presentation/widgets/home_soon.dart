
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class homeSoon extends StatelessWidget {
  const homeSoon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          tr('soon'),
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
