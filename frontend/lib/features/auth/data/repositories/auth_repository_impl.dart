import 'package:frontend/features/auth/data/models/user_model.dart';
import 'package:frontend/features/auth/data/sources/auth_remote_source.dart';
import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteSource _source;
  AuthRepositoryImpl(this._source);

  @override
  Future<UserModel> login(String identifier, String password) =>
      _source.login(identifier, password);

  @override
  Future<void> signup(String username, String email, String password) =>
      _source.signup(username, email, password);

  @override
  Future<void> forgotPassword(String email) =>
      _source.forgotPassword(email);

  @override
  Future<void> resetPassword(String email, String otp, String newPassword) =>
      _source.resetPassword(email, otp, newPassword);
}
