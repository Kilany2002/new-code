abstract class RegisterRepository {
  Future<void> register(String email, String password, String firstName, String lastName, String phoneNumber);
}