import 'package:e7gezly/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository authRepository;

  LoginUseCase({required this.authRepository});

  Future<void> call(String email, String password) async {
    return await authRepository.login(email, password);
  }
}