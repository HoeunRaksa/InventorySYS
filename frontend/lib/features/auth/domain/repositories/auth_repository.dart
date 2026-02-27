import 'package:frontend/features/auth/data/models/user_model.dart';

/// Defines what auth operations are available. (Contract)
/// Presentation depends on this — never on the impl directly.
abstract class AuthRepository {
  Future<UserModel> login(String identifier, String password);
  Future<void> signup(String username, String email, String password);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String email, String otp, String newPassword);
}
