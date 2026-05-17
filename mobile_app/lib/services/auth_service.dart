class AuthService {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      return true;
    }
    return false;
  }

  Future<bool> signup(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isAuthenticated = false;
  }
}
