import 'package:flutter/material.dart';
import '../../application/services/i_auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final IAuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  RegisterViewModel({required IAuthService authService}) : _authService = authService;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password, String confirmPassword) async {
    if (name.trim().isEmpty || email.trim().isEmpty || password.trim().isEmpty || confirmPassword.trim().isEmpty) {
      _errorMessage = 'Vui lòng điền đầy đủ tất cả các trường.';
      notifyListeners();
      return false;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim())) {
      _errorMessage = 'Định dạng email không hợp lệ.';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _errorMessage = 'Mật khẩu phải chứa ít nhất 6 ký tự.';
      notifyListeners();
      return false;
    }

    if (password != confirmPassword) {
      _errorMessage = 'Mật khẩu xác nhận không khớp.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      await _authService.register(name.trim(), email.trim(), password.trim());
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
