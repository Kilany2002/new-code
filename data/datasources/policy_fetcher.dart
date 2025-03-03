// lib/utils/policy_fetcher.dart
import 'package:http/http.dart' as http;

class PolicyFetcher {
  static const String policyUrl = 'https://raw.githubusercontent.com/Kilany2002/Privacy-Policy/main/privacy-policy.md';

  static Future<String> fetchPrivacyPolicy() async {
    try {
      final response = await http.get(Uri.parse(policyUrl));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load privacy policy');
      }
    } catch (e) {
      throw Exception('Error fetching privacy policy: $e');
    }
  }
}
