// lib/features/settings/presentation/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../features/auth/application/services/auth_service_impl.dart';
import '../../application/providers/settings_provider.dart';

/// Màn hình cài đặt ứng dụng.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SettingsProvider>(context, listen: false).loadSettings();
    });
  }

  Future<void> _logout() async {
    final authService = Provider.of<AuthServiceImpl>(context, listen: false);
    await authService.logout();
    if (mounted) {
      context.go(AppRouter.login);
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Quản Lý Thu Chi',
      applicationVersion: 'v1.2.0',
      applicationIcon: Icon(
        IconlyBold.wallet,
        size: 48,
        color: Colors.orange[800],
      ),
      children: const [
        Text('Ứng dụng quản lý thu chi cá nhân.'),
        SizedBox(height: 8),
        Text('Flutter • Provider • SQLite • Material 3'),
      ],
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chính sách bảo mật'),
        content: const SingleChildScrollView(
          child: Text(
            'Chúng tôi chỉ lưu dữ liệu trên thiết bị của bạn (SQLite, SharedPreferences). '
            'Thông tin không được chia sẻ với bên thứ ba. '
            'Bạn có thể xóa dữ liệu bằng cách gỡ cài đặt ứng dụng.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Cài Đặt',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: settingsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SettingsCard(
                  children: [
                    ListTile(
                      leading: const Icon(IconlyLight.profile),
                      title: const Text('Hồ sơ cá nhân'),
                      subtitle: const Text('Xem và chỉnh sửa thông tin'),
                      trailing: const Icon(IconlyLight.arrow_right_2),
                      onTap: () => context.push(AppRouter.profile),
                    ),
                    
                    ListTile(
                      leading: const Icon(IconlyLight.category),
                      title: const Text('Quản lý danh mục'),
                      subtitle: const Text('Tùy chỉnh đề mục chi tiêu & thu nhập'),
                      trailing: const Icon(IconlyLight.arrow_right_2),
                      onTap: () => context.push(AppRouter.categories),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsCard(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(IconlyLight.show),
                      title: const Text('Dark Mode'),
                      subtitle: const Text('Bật/Tắt giao diện tối'),
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme(value);
                        settingsProvider.saveThemePreference(value);
                      },
                    ),
                    
                    ListTile(
                      leading: const Icon(IconlyLight.wallet),
                      title: const Text('Đơn vị tiền tệ'),
                      subtitle: Text(settingsProvider.currency),
                      trailing: DropdownButton<String>(
                        value: settingsProvider.currency,
                        underline: const SizedBox.shrink(),
                        items: SettingsProvider.supportedCurrencies
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            settingsProvider.setCurrency(value);
                          }
                        },
                      ),
                    ),
                    
                    SwitchListTile(
                      secondary: const Icon(IconlyLight.notification),
                      title: const Text('Thông báo'),
                      subtitle: Text(
                        settingsProvider.notificationEnabled
                            ? 'Đang bật'
                            : 'Đang tắt',
                      ),
                      value: settingsProvider.notificationEnabled,
                      onChanged: settingsProvider.setNotification,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsCard(
                  children: [
                    ListTile(
                      leading: const Icon(IconlyLight.info_square),
                      title: const Text('Giới thiệu'),
                      trailing: const Icon(IconlyLight.arrow_right_2),
                      onTap: _showAboutDialog,
                    ),
                    
                    ListTile(
                      leading: const Icon(IconlyLight.shield_done),
                      title: const Text('Chính sách bảo mật'),
                      trailing: const Icon(IconlyLight.arrow_right_2),
                      onTap: _showPrivacyPolicy,
                    ),
                    
                    ListTile(
                      leading: const Icon(
                        IconlyBold.logout,
                        color: Colors.redAccent,
                      ),
                      title: const Text('Đăng xuất'),
                      onTap: _logout,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Column(children: children),
    );
  }
}
