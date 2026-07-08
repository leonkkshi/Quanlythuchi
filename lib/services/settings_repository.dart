// lib/services/settings_repository.dart

import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/app_settings.dart';

/// Repository lưu cài đặt vào SharedPreferences và SQLite.
class SettingsRepository {
  static const _currencyKey = 'settings_currency';
  static const _notificationKey = 'settings_notification';
  static const _themeKey = 'is_dark';

  final DatabaseHelper _db;

  SettingsRepository({DatabaseHelper? dbHelper})
      : _db = dbHelper ?? DatabaseHelper.instance;

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final dbSettings = await _db.getSettings();

    final isDark = prefs.getBool(_themeKey);
    final theme = isDark == null
        ? (dbSettings?['theme'] as String? ?? 'system')
        : (isDark ? 'dark' : 'light');

    return AppSettings(
      theme: theme,
      currency: prefs.getString(_currencyKey) ??
          dbSettings?['currency'] as String? ??
          'VND',
      notification: prefs.getBool(_notificationKey) ??
          ((dbSettings?['notification'] as int? ?? 1) == 1),
    );
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, settings.currency);
    await prefs.setBool(_notificationKey, settings.notification);
    await _db.upsertSettings(settings.toMap());
  }

  Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
    final current = await loadSettings();
    await _db.upsertSettings(
      current.copyWith(theme: isDark ? 'dark' : 'light').toMap(),
    );
  }
}
