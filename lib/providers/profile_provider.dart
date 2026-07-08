// lib/providers/profile_provider.dart

import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/profile_repository.dart';

/// Provider quản lý hồ sơ người dùng.
class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileProvider({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  UserProfile? _profile;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  UserProfile? get profile => _profile;

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.getProfile(userId);
      if (_profile == null) {
        _errorMessage = 'Không tìm thấy hồ sơ người dùng.';
      }
    } catch (e) {
      _errorMessage = 'Không thể tải hồ sơ: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String avatarSeed,
  }) async {
    final nameError = _validateName(name);
    if (nameError != null) {
      _errorMessage = nameError;
      notifyListeners();
      return false;
    }

    final emailError = _validateEmail(email);
    if (emailError != null) {
      _errorMessage = emailError;
      notifyListeners();
      return false;
    }

    final phoneError = _validatePhone(phone);
    if (phoneError != null) {
      _errorMessage = phoneError;
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final avatarUrl =
          'https://api.dicebear.com/7.x/adventurer/png?seed=${Uri.encodeComponent(avatarSeed)}';

      final updated = (_profile ??
              UserProfile(
                id: userId,
                name: name,
                email: email,
              ))
          .copyWith(
        name: name.trim(),
        email: email.trim().toLowerCase(),
        phone: phone.trim(),
        avatar: avatarUrl,
      );

      await _repository.updateProfile(updated);
      _profile = updated;
      return true;
    } catch (e) {
      _errorMessage = 'Không thể lưu hồ sơ: $e';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  String? _validateName(String value) {
    if (value.trim().isEmpty) return 'Tên không được để trống.';
    if (value.trim().length < 2) return 'Tên phải có ít nhất 2 ký tự.';
    return null;
  }

  String? _validateEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) return 'Email không được để trống.';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(email)) return 'Email không hợp lệ.';
    return null;
  }

  String? _validatePhone(String value) {
    final phone = value.trim();
    if (phone.isEmpty) return 'Số điện thoại không được để trống.';
    if (!RegExp(r'^[0-9]{9,11}$').hasMatch(phone)) {
      return 'Số điện thoại phải gồm 9–11 chữ số.';
    }
    return null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
