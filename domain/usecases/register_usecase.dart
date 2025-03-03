import 'package:e7gezly/domain/repositories/register_repository.dart';

class RegisterUseCase {
  final RegisterRepository registerRepository;

  RegisterUseCase({required this.registerRepository});

  Future<void> call(String email, String password, String firstName, String lastName, String phoneNumber) async {
    return await registerRepository.register(email, password, firstName, lastName, phoneNumber);
  }
}