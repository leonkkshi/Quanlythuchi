// lib/features/profile/presentation/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../features/auth/application/services/auth_service_impl.dart';
import '../../../../providers/profile_provider.dart';
import '../../../../widgets/async_state_view.dart';
import '../widgets/profile_header.dart';

/// Màn hình hồ sơ người dùng.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    final authService = Provider.of<AuthServiceImpl>(context, listen: false);
    final user = await authService.getCurrentUser();
    if (user != null && mounted) {
      await Provider.of<ProfileProvider>(context, listen: false)
          .loadProfile(user.id);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final authService = Provider.of<AuthServiceImpl>(context, listen: false);
    await authService.logout();
    if (mounted) {
      context.go(AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Hồ Sơ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: _loadProfile,
            child: AsyncStateView(
              isLoading: provider.isLoading,
              errorMessage: provider.errorMessage,
              isEmpty: provider.profile == null && !provider.isLoading,
              emptyTitle: 'Không có hồ sơ',
              emptySubtitle: 'Không tìm thấy thông tin người dùng.',
              onRetry: _loadProfile,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  if (provider.profile != null)
                    ProfileHeader(profile: provider.profile!),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await context.push(AppRouter.editProfile);
                      if (mounted) _loadProfile();
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Chỉnh sửa hồ sơ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded, color: Colors.red),
                    label: const Text(
                      'Đăng xuất',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
