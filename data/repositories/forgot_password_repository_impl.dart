import 'package:firebase_auth/firebase_auth.dart';
import 'package:e7gezly/domain/repositories/forgot_password_repository.dart';

class ForgotPasswordRepositoryImpl implements ForgotPasswordRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}