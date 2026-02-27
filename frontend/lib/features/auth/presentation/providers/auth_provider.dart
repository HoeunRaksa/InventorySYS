import 'package:flutter/material.dart';
import 'package:frontend/core/network/api_exception.dart';
import 'package:frontend/core/storage/token_storage.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:frontend/features/auth/data/sources/auth_remote_source.dart';
import 'package:frontend/features/auth/domain/usecases/login_usecase.dart';

class AuthProvider with ChangeNotifier {
  final LoginUseCase _login;

  String? _token;
  String? _username;
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get username => _username;

  AuthProvider()
      : _login = LoginUseCase(
          AuthRepositoryImpl(AuthRemoteSource()),
        ) {
    _restore();
  }

  Future<void> _restore() async {
    _token    = await TokenStorage.read();
    _username = await TokenStorage.readUsername();
    notifyListeners();
  }

  /// Returns null on success, error message on failure.
  Future<String?> login(String identifier, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _login(identifier, password);
      await TokenStorage.save(token: user.token, username: user.username);
      _token    = user.token;
      _username = user.username;
      _isLoading = false;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return 'Connection error. Please try again.';
    }
  }

  Future<void> logout() async {
    await TokenStorage.clear();
    _token = _username = null;
    notifyListeners();
  }
}
