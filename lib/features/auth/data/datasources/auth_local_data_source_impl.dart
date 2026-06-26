import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../dtos/user_dto.dart';
import 'i_auth_local_data_source.dart';

class AuthLocalDataSourceImpl implements IAuthLocalDataSource {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<void> saveToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  @override
  Future<void> deleteToken() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
  }

  @override
  Future<void> saveUser(UserDto user) async {
    final prefs = await _prefs;
    final userJson = json.encode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  @override
  Future<UserDto?> getUser() async {
    final prefs = await _prefs;
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    try {
      final decoded = json.decode(userJson) as Map<String, dynamic>;
      return UserDto.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteUser() async {
    final prefs = await _prefs;
    await prefs.remove(_userKey);
  }

  @override
  Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
