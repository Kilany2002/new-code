import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e7gezly/data/models/home_view_model.dart';
import 'package:e7gezly/data/models/image_veiw_model.dart';
import 'package:e7gezly/data/models/menu_view_model.dart';
import 'package:e7gezly/data/models/notification_view_model.dart';
import 'package:e7gezly/data/repositories/user_repository_impl.dart';
import 'package:e7gezly/domain/usecases/get_notifications.dart';
import 'package:e7gezly/domain/usecases/get_user.dart';
import 'package:e7gezly/home.dart';
import 'package:e7gezly/presentation/screens/forgot_password_screen.dart';
import 'package:e7gezly/presentation/screens/login_screen.dart';
import 'package:e7gezly/presentation/screens/register_screen.dart';
import 'package:e7gezly/presentation/screens/auth_check.dart';
import 'package:e7gezly/presentation/screens/Privacy_policy_screen.dart';
import 'package:e7gezly/user/settings-screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:e7gezly/presentation/screens/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MenuViewModel()),
        ChangeNotifierProvider(create: (_) => notificationViewModel()),
        ChangeNotifierProvider(create: (_) => ImageViewModel()),
        ChangeNotifierProvider(
          create: (_) {
            final firestore = FirebaseFirestore.instance;
            final storage = FirebaseStorage.instance;
            final userRepo = UserRepositoryImpl(firestore, storage);
            final getUserData = GetUserData(userRepo);
            final getNotifications = GetNotifications(userRepo);
            return HomeViewModel(getUserData, getNotifications)..loadData();
          },
        ),
      ],
      child: MaterialApp(
        title: 'E7GEZLY',
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/authCheck': (context) => const AuthCheck(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot_password': (context) => ForgotPasswordScreen(),
          '/privacy_policy': (context) => const PrivacyPolicyPage(),
          '/home': (context) => HomeScreen(),
          '/settings': (context) => SettingsScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
