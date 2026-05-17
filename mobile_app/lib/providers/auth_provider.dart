import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  bool _isLoading = false;
  String _error = '';

  AuthProvider(this._authService);

  bool get isAuthenticated => _authService.isAuthenticated;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      bool success = await _authService.login(email, password);
      if (!success) {
        _error = 'Invalid email or password';
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      bool success = await _authService.signup(name, email, password);
      if (!success) {
        _error = 'Failed to create account. Please check your details.';
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}
