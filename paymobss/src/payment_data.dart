import 'package:e7gezly/paymobss/models/style.dart';
import 'package:e7gezly/paymobss/models/user_data.dart';

class PaymentData {
  static String _apiKey =
      "ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2T1RnMU56azNMQ0p1WVcxbElqb2lNVGN5TkRFNE56ZzFOaTQxT1RBeU56TWlmUS44Z0RXdTAxNnk5MGt0QkZ2Z2tfNzFGRVpTQktWeFVBZUpZZUs3WU9MRXNQcmRDRWVLbTFVUEluRk93Um90QlVpdlFycEFHcFkzTFEzY3liNC0yaE9ZUQ==";
  static String _integrationCardId = "4612972";
  static String _integrationMobileWalletId = "4612975";
  static String _iframeId = "856699";
  static UserData? _userData = UserData();
  static Style? _style = Style();

  static void initialize(
      {required String apiKey,
      required String iframeId,
      required String integrationCardId,
      required String integrationMobileWalletId,
      UserData? userData,
      Style? style}) {
    PaymentData._apiKey = apiKey;
    PaymentData._iframeId = iframeId;
    PaymentData._integrationCardId = integrationCardId;
    PaymentData._integrationMobileWalletId = integrationMobileWalletId;
    PaymentData._userData = userData;
    PaymentData._style = style;
  }

  String get apiKey => PaymentData._apiKey;
  String get integrationCardId => PaymentData._integrationCardId;
  String get integrationMobileWalletId =>
      PaymentData._integrationMobileWalletId;
  String get iframeId => PaymentData._iframeId;
  UserData? get userData => PaymentData._userData;
  Style? get style => PaymentData._style;
}
