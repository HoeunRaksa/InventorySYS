import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/api_endpoints.dart';
import 'package:frontend/features/auth/data/models/user_model.dart';

/// Calls the remote auth API. Only talks to ApiClient — no business logic here.
class AuthRemoteSource {
  Future<UserModel> login(String identifier, String password) async {
    final data = await ApiClient.post(
      ApiEndpoints.login,
      {'identifier': identifier, 'password': password},
      auth: false,
    );
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> signup(String username, String email, String password) async {
    await ApiClient.post(
      ApiEndpoints.signup,
      {'username': username, 'email': email, 'password': password},
      auth: false,
    );
  }

  Future<void> forgotPassword(String email) async {
    await ApiClient.post(
      ApiEndpoints.forgotPassword,
      {'email': email},
      auth: false,
    );
  }

  Future<void> resetPassword(String email, String otp, String newPassword) async {
    await ApiClient.post(
      ApiEndpoints.resetPassword,
      {'email': email, 'otp': otp, 'newPassword': newPassword},
      auth: false,
    );
  }
}
