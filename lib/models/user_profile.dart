// lib/models/user_profile.dart

/// Hồ sơ người dùng lưu trong SQLite.
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    DateTime? createdAt;
    final rawCreatedAt = map['createdAt'] as String?;
    if (rawCreatedAt != null && rawCreatedAt.isNotEmpty) {
      createdAt = DateTime.tryParse(rawCreatedAt);
    }

    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      avatar: map['avatarUrl'] as String? ?? map['avatar'] as String?,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatar,
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt,
    );
  }
}
