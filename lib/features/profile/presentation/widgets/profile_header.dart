// lib/features/profile/presentation/widgets/profile_header.dart

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/user_profile.dart';

/// Header hiển thị avatar và thông tin cơ bản.
class ProfileHeader extends StatelessWidget {
  final UserProfile profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final memberSince = profile.createdAt != null
        ? DateFormat('dd/MM/yyyy').format(profile.createdAt!)
        : 'Chưa cập nhật';

    final avatarUrl = profile.avatar ??
        'https://api.dicebear.com/7.x/adventurer/png?seed=${profile.name}';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor: Colors.orange.withOpacity(0.15),
              backgroundImage: NetworkImage(avatarUrl),
            ),
            const SizedBox(height: 16),
            Text(
              profile.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoTile(
              icon: IconlyLight.message,
              label: 'Email',
              value: profile.email,
            ),
            _InfoTile(
              icon: IconlyLight.call,
              label: 'Điện thoại',
              value: profile.phone ?? 'Chưa cập nhật',
            ),
            _InfoTile(
              icon: IconlyLight.calendar,
              label: 'Thành viên từ',
              value: memberSince,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.orange[800]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
