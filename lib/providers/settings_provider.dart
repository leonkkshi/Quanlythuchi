// lib/providers/settings_provider.dart

import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/settings_repository.dart';

/// Provider quản lý cài đặt ứng dụng.
class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;

  SettingsProvider({SettingsRepository? repository})
      : _repository = repository ?? SettingsRepository();

  bool _isLoading = false;
  String? _errorMessage;
  AppSettings _settings = const AppSettings();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AppSettings get settings => _settings;
  String get currency => _settings.currency;
  bool get notificationEnabled => _settings.notification;

  static const supportedCurrencies = ['VND', 'USD', 'EUR'];

  Future<void> loadSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _repository.loadSettings();
    } catch (e) {
      _errorMessage = 'Không thể tải cài đặt: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setCurrency(String currency) async {
    if (!supportedCurrencies.contains(currency)) return;
    _settings = _settings.copyWith(currency: currency);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setNotification(bool enabled) async {
    _settings = _settings.copyWith(notification: enabled);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> saveThemePreference(bool isDark) async {
    _settings = _settings.copyWith(theme: isDark ? 'dark' : 'light');
    notifyListeners();
    await _repository.saveTheme(isDark);
  }
}
