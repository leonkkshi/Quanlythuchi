import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../features/auth/application/services/auth_service_impl.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../transaction/presentation/views/transaction_input_view.dart';
import '../../../transaction/presentation/views/transaction_calendar_view.dart';
import '../../../transaction/presentation/views/transaction_report_view.dart';
import '../../../transaction/application/providers/transaction_provider.dart';
import '../../../category/presentation/views/budget_view.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;


  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const TransactionInputView(),
      const TransactionCalendarView(),
      const TransactionReportView(),
      const BudgetView(),
      const _SettingsTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = Colors.orange[800] ?? Colors.orange;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          selectedItemColor: primaryColor,
          unselectedItemColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_note_rounded, size: 28),
              activeIcon: Icon(Icons.edit_note_rounded, size: 28),
              label: 'Nhập vào',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined, size: 24),
              activeIcon: Icon(Icons.calendar_month_rounded, size: 24),
              label: 'Lịch',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline_rounded, size: 24),
              activeIcon: Icon(Icons.pie_chart_rounded, size: 24),
              label: 'Báo cáo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined, size: 24),
              activeIcon: Icon(Icons.account_balance_wallet_rounded, size: 24),
              label: 'Ngân sách',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz_rounded, size: 26),
              activeIcon: Icon(Icons.more_horiz_rounded, size: 26),
              label: 'Khác',
            ),
          ],
        ),
      ),
    );
  }
}



class _SettingsTab extends StatefulWidget {
  const _SettingsTab();

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  bool _pinEnabled = false;
  String _pinCode = '';

  @override
  void initState() {
    super.initState();
    _loadPinSettings();
  }

  Future<void> _loadPinSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pinEnabled = prefs.getBool('app_lock_enabled') ?? false;
      _pinCode = prefs.getString('app_lock_pin') ?? '';
    });
  }

  void _logout(BuildContext context) async {
    final authService = Provider.of<AuthServiceImpl>(context, listen: false);
    await authService.logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    }
  }

  Future<void> _togglePinLock(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      if (_pinCode.isEmpty) {
        _showSetupPinDialog();
      } else {
        await prefs.setBool('app_lock_enabled', true);
        setState(() {
          _pinEnabled = true;
        });
      }
    } else {
      await prefs.setBool('app_lock_enabled', false);
      setState(() {
        _pinEnabled = false;
      });
    }
  }

  void _showSetupPinDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: const Text('Thiết lập mã PIN 4 số', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Nhập 4 số PIN',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('HỦY', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
              ),
              onPressed: () async {
                final pin = controller.text.trim();
                if (pin.length == 4 && int.tryParse(pin) != null) {
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('app_lock_pin', pin);
                  await prefs.setBool('app_lock_enabled', true);
                  navigator.pop();
                  setState(() {
                    _pinCode = pin;
                    _pinEnabled = true;
                  });
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Đã kích hoạt khóa PIN thành công!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mã PIN phải gồm đúng 4 chữ số!')),
                  );
                }
              },
              child: const Text('LƯU', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportToCsv() async {
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final txs = txProvider.transactions;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    if (txs.isEmpty) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Không có dữ liệu giao dịch để xuất!')),
      );
      return;
    }

    try {
      final csvBuffer = StringBuffer();
      csvBuffer.writeln('Mã giao dịch,Số tiền,Ngày,Loại,Ghi chú,Mã danh mục');
      for (final tx in txs) {
        csvBuffer.writeln('${tx.id},${tx.amount},${tx.date},${tx.type},"${tx.note ?? ''}",${tx.categoryId}');
      }

      final directory = Directory('csv_exports');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final file = File('csv_exports/transactions_export.csv');
      await file.writeAsString(csvBuffer.toString(), encoding: utf8);

      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Đã xuất CSV thành công tại: csv_exports/transactions_export.csv'),
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Lỗi xuất dữ liệu: $e')),
      );
    }
  }

  void _showEditProfileBottomSheet(String currentName, String currentAvatarUrl) {
    final nameController = TextEditingController(text: currentName);
    
    String currentSeed = currentName;
    try {
      final uri = Uri.parse(currentAvatarUrl);
      currentSeed = uri.queryParameters['seed'] ?? currentName;
    } catch (_) {}
    
    final seedController = TextEditingController(text: currentSeed);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Chỉnh sửa thông tin cá nhân',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên người dùng',
                  hintText: 'Nhập tên của bạn',
                ),
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: seedController,
                decoration: const InputDecoration(
                  labelText: 'Từ khóa ảnh đại diện (Seed)',
                  hintText: 'Nhập từ khóa tạo avatar',
                ),
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800] ?? Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final newName = nameController.text.trim();
                  final newSeed = seedController.text.trim();
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  if (newName.isEmpty || newSeed.isEmpty) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
                    );
                    return;
                  }

                  final authService = Provider.of<AuthServiceImpl>(context, listen: false);
                  final user = await authService.getCurrentUser();
                  if (user != null) {
                    final newAvatarUrl = 'https://api.dicebear.com/7.x/adventurer/png?seed=${Uri.encodeComponent(newSeed)}';
                    await DatabaseHelper.instance.updateUserProfile(user.id, newName, newAvatarUrl);
                    
                    final prefs = await SharedPreferences.getInstance();
                    final userJson = prefs.getString('auth_user');
                    if (userJson != null) {
                      final Map<String, dynamic> userData = json.decode(userJson);
                      userData['name'] = newName;
                      userData['avatarUrl'] = newAvatarUrl;
                      await prefs.setString('auth_user', json.encode(userData));
                    }
                    
                    navigator.pop();
                    setState(() {});
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('Đã cập nhật thông tin cá nhân!')),
                    );
                  }
                },
                child: const Text('LƯU THAY ĐỔI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authService = Provider.of<AuthServiceImpl>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Cài Đặt', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder(
        future: authService.getCurrentUser(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          final userName = user?.name ?? 'Người dùng';
          final userEmail = user?.email ?? 'Chưa cập nhật email';
          final avatarUrl = user?.avatarUrl ?? 'https://api.dicebear.com/7.x/adventurer/png?seed=Default';

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              InkWell(
                onTap: () => _showEditProfileBottomSheet(userName, avatarUrl),
                borderRadius: BorderRadius.circular(16),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.orange.withOpacity(0.2),
                          backgroundImage: NetworkImage(avatarUrl),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      userName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                    color: Colors.orange[800] ?? Colors.orange,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userEmail,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                elevation: 2,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.style_rounded, color: Colors.blue),
                      title: const Text('Chủ đề tối (Dark Theme)'),
                      subtitle: const Text('Bật/Tắt chế độ giao diện tối'),
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (val) {
                          themeProvider.toggleTheme(val);
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.security_rounded, color: Colors.purple),
                      title: const Text('Khóa ứng dụng bằng PIN'),
                      subtitle: Text(_pinEnabled ? 'Đã kích hoạt' : 'Chưa kích hoạt'),
                      trailing: Switch(
                        value: _pinEnabled,
                        onChanged: _togglePinLock,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.category_rounded, color: Colors.amber),
                      title: const Text('Quản lý danh mục'),
                      subtitle: const Text('Tùy chỉnh đề mục chi tiêu & thu nhập'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.categories);
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.ios_share_rounded, color: Colors.teal),
                      title: const Text('Xuất báo cáo dữ liệu'),
                      subtitle: const Text('Xuất lịch sử giao dịch ra file CSV'),
                      trailing: const Icon(Icons.file_download_outlined),
                      onTap: _exportToCsv,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded, color: Colors.green),
                      title: const Text('Phiên bản ứng dụng'),
                      trailing: const Text('v1.1.0', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      title: const Text('Đăng xuất'),
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
