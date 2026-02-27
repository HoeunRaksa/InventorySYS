import 'package:frontend/features/auth/data/models/user_model.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repo;
  LoginUseCase(this._repo);
  Future<UserModel> call(String identifier, String password) =>
      _repo.login(identifier, password);
}
