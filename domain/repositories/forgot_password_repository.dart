abstract class ForgotPasswordRepository {
  Future<void> sendPasswordResetEmail(String email);
}