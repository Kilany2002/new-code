import 'package:e7gezly/domain/repositories/forgot_password_repository.dart';

class ForgotPasswordUseCase {
  final ForgotPasswordRepository forgotPasswordRepository;

  ForgotPasswordUseCase({required this.forgotPasswordRepository});

  Future<void> call(String email) async {
    return await forgotPasswordRepository.sendPasswordResetEmail(email);
  }
}