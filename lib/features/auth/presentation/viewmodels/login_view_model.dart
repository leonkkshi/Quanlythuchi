import 'package:flutter/material.dart';
import '../../application/services/i_auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final IAuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  LoginViewModel({required IAuthService authService}) : _authService = authService;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    // Validate inputs
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = 'Email và mật khẩu không được để trống.';
      notifyListeners();
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim())) {
      _errorMessage = 'Định dạng email không hợp lệ.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      await _authService.login(email.trim(), password.trim());
      _isSuccess = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _isSuccess = false;
      notifyListeners();
      return false;
    }
  }
}
