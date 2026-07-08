import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../category/presentation/views/budget_view.dart';
import '../../../reports/presentation/pages/reports_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../transaction/presentation/views/transaction_calendar_view.dart';
import '../../../transaction/presentation/views/transaction_input_view.dart';
import 'home_page.dart';

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
      HomePage(onNavigateToTab: _changeTab),
      const TransactionInputView(),
      const TransactionCalendarView(),
      const ReportsPage(),
      const BudgetView(),
      const SettingsPage(),
    ];
  }

  void _changeTab(int index) {
    if (index < 0 || index >= _pages.length) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceCardDark : AppColors.canvasLight,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.28 : 0.06),
              blurRadius: 18,
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
          backgroundColor: isDark ? AppColors.surfaceCardDark : AppColors.canvasLight,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: isDark ? AppColors.mutedStrong : AppColors.mutedStrong,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined, size: 24),
              activeIcon: Icon(Icons.dashboard_rounded, size: 24),
              label: 'Tổng quan',
            ),
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
