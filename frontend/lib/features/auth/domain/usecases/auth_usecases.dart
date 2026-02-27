import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class SignupUseCase {
  final AuthRepository _repo;
  SignupUseCase(this._repo);
  Future<void> call(String username, String email, String password) =>
      _repo.signup(username, email, password);
}

class ForgotPasswordUseCase {
  final AuthRepository _repo;
  ForgotPasswordUseCase(this._repo);
  Future<void> call(String email) => _repo.forgotPassword(email);
}

class ResetPasswordUseCase {
  final AuthRepository _repo;
  ResetPasswordUseCase(this._repo);
  Future<void> call(String email, String otp, String newPassword) =>
      _repo.resetPassword(email, otp, newPassword);
}
