import 'package:e7gezly/presentation/screens/login_screen.dart';
import 'package:e7gezly/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return LoginScreen(); 
          } else {
            return HomeScreen(); 
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(), 
            ),
          );
        }
      },
    );
  }
}
