import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> getCurrentUser();
  Future<void> signOut();

  login(String email, String password) {}
}