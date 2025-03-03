// lib/pages/privacy_policy_page.dart
import 'package:e7gezly/core/constants/colors.dart';
import 'package:e7gezly/data/datasources/policy_fetcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_scaffold.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        title: tr('privacy_policy'),
        showBackButton: true,
      ),
      body: FutureBuilder<String>(
        future: PolicyFetcher.fetchPrivacyPolicy(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.prColor),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                tr('error_loading_policy'),
                style: const TextStyle(color: AppColors.whColor),
              ),
            );
          }

          return Markdown(
            data: snapshot.data ?? '',
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(color: AppColors.whColor, fontSize: 16),
              h1: const TextStyle(
                color: AppColors.whColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              h2: const TextStyle(
                color: AppColors.whColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              listBullet: const TextStyle(color: AppColors.whColor),
            ),
          );
        },
      ),
    );
  }
}
