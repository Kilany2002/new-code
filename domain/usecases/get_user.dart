
import 'package:e7gezly/domain/entities/user.dart';
import 'package:e7gezly/domain/repositories/user_repository.dart';


class GetUserData {
  final UserRepository repository;

  GetUserData(this.repository);

  Future<User> execute(String userId) async {
    return await repository.getUser(userId);
  }
}