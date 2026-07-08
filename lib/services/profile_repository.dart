// lib/services/profile_repository.dart

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/user_profile.dart';

/// Repository quản lý hồ sơ người dùng trong SQLite.
class ProfileRepository {
  final DatabaseHelper _db;

  ProfileRepository({DatabaseHelper? dbHelper})
      : _db = dbHelper ?? DatabaseHelper.instance;

  Future<UserProfile?> getProfile(String userId) async {
    final map = await _db.getUserById(userId);
    if (map == null) return null;
    return UserProfile.fromMap(map);
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _db.updateUserProfileFull(profile.toUpdateMap());
    await _syncAuthCache(profile);
  }

  /// Đồng bộ cache đăng nhập sau khi cập nhật profile.
  Future<void> _syncAuthCache(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('auth_user');
    if (userJson == null) return;

    final Map<String, dynamic> userData = json.decode(userJson);
    userData['name'] = profile.name;
    userData['email'] = profile.email;
    userData['avatarUrl'] = profile.avatar;
    await prefs.setString('auth_user', json.encode(userData));
  }
}
