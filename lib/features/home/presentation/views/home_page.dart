import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/application/services/auth_service_impl.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../category/application/providers/budget_provider.dart';
import '../../../category/application/providers/category_provider.dart';
import '../../../category/data/models/category_model.dart';
import '../../../transaction/application/providers/transaction_provider.dart';
import '../../../transaction/data/models/transaction_model.dart';

class HomePage extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const HomePage({super.key, this.onNavigateToTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? _currentUser;
  bool _isLoading = true;
  late final int _selectedYear;
  late final int _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final authService = Provider.of<AuthServiceImpl>(context, listen: false);
    final user = await authService.getCurrentUser();

    if (!mounted) return;

    if (user == null) {
      setState(() {
        _currentUser = null;
        _isLoading = false;
      });
      return;
    }

    final period = _periodKey(_selectedYear, _selectedMonth);
    await Future.wait([
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).loadTransactions(user.id),
      Provider.of<CategoryProvider>(
        context,
        listen: false,
      ).loadCategories(user.id),
      Provider.of<BudgetProvider>(
        context,
        listen: false,
      ).loadBudgets(user.id, period),
    ]);

    if (!mounted) return;

    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  String _periodKey(int year, int month) {
    return '$year-${month.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(double value) {
    final sign = value < 0 ? '-' : '';
    final digits = value.abs().round().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - i;
      buffer.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return '$sign${buffer.toString()} đ';
  }

  String _formatDateLabel(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
  }

  IconData _getIconData(int codePoint) {
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  Color _getColorFromHex(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.orange;
    }
  }

  CategoryModel? _findCategory(List<CategoryModel> categories, String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  List<TransactionModel> _currentMonthTransactions(
    List<TransactionModel> transactions,
  ) {
    return transactions.where((transaction) {
      final parts = transaction.date.split('-');
      if (parts.length < 2) return false;
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      return year == _selectedYear && month == _selectedMonth;
    }).toList();
  }

  _TopCategory? _topExpenseCategory(
    List<TransactionModel> transactions,
    List<CategoryModel> categories,
  ) {
    final totals = <String, double>{};

    for (final transaction in transactions) {
      if (transaction.type != 'expense') continue;
      totals[transaction.categoryId] =
          (totals[transaction.categoryId] ?? 0) + transaction.amount;
    }

    if (totals.isEmpty) return null;

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;
    final category = _findCategory(categories, top.key);

    return _TopCategory(
      name: category?.name ?? 'Chưa phân loại',
      amount: top.value,
      iconCode: category?.iconCode ?? Icons.category_outlined.codePoint,
      colorHex: category?.colorHex ?? '#F97316',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = Colors.orange[800] ?? Colors.orange;
    final surfaceColor = isDark ? const Color(0xFF0F172A) : Colors.white;

    final txProvider = context.watch<TransactionProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final budgetProvider = context.watch<BudgetProvider>();

    final monthlyTransactions = _currentMonthTransactions(
      txProvider.transactions,
    );

    final totalIncome = monthlyTransactions
        .where((transaction) => transaction.type == 'income')
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
    final totalExpense = monthlyTransactions
        .where((transaction) => transaction.type == 'expense')
        .fold<double>(0, (sum, transaction) => sum + transaction.amount);
    final balance = totalIncome - totalExpense;

    final recentTransactions = [...txProvider.transactions]
      ..sort((a, b) => b.date.compareTo(a.date));
    final visibleRecentTransactions = recentTransactions.take(5).toList();

    final topCategory = _topExpenseCategory(
      monthlyTransactions,
      categoryProvider.categories,
    );

    final totalBudget = budgetProvider.budgets
        .where((budget) => budget.categoryId == 'total')
        .fold<double>(0, (sum, budget) => sum + budget.amount);
    final budgetProgress = totalBudget > 0
        ? (totalExpense / totalBudget).clamp(0.0, 1.0)
        : 0.0;
    final remainingBudget = totalBudget - totalExpense;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF020617)
          : const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            _buildHeader(context, primaryColor, isDark),
            const SizedBox(height: 18),
            _buildBalanceCard(
              primaryColor: primaryColor,
              balance: balance,
              totalIncome: totalIncome,
              totalExpense: totalExpense,
              transactionCount: monthlyTransactions.length,
            ),
            const SizedBox(height: 18),
            _buildQuickActions(primaryColor),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _buildInsightCard(
                    surfaceColor: surfaceColor,
                    isDark: isDark,
                    icon: Icons.savings_outlined,
                    color: remainingBudget >= 0
                        ? Colors.green
                        : Colors.redAccent,
                    title: 'Ngân sách tháng',
                    value: totalBudget > 0
                        ? _formatCurrency(totalBudget)
                        : 'Chưa đặt',
                    subtitle: totalBudget > 0
                        ? 'Còn lại ${_formatCurrency(remainingBudget)}'
                        : 'Thiết lập ở tab Ngân sách',
                    progress: totalBudget > 0 ? budgetProgress : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInsightCard(
                    surfaceColor: surfaceColor,
                    isDark: isDark,
                    icon: Icons.local_fire_department_outlined,
                    color: topCategory == null
                        ? primaryColor
                        : _getColorFromHex(topCategory.colorHex),
                    title: 'Chi nhiều nhất',
                    value: topCategory?.name ?? 'Chưa có',
                    subtitle: topCategory == null
                        ? 'Chưa có chi tiêu tháng này'
                        : _formatCurrency(topCategory.amount),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildRecentHeader(primaryColor),
            const SizedBox(height: 12),
            if (txProvider.isLoading || categoryProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (visibleRecentTransactions.isEmpty)
              _buildEmptyState(surfaceColor, isDark)
            else
              ...visibleRecentTransactions.map(
                (transaction) => _buildTransactionItem(
                  transaction,
                  categoryProvider.categories,
                  surfaceColor,
                  isDark,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color primaryColor, bool isDark) {
    final avatarUrl = _currentUser?.avatarUrl;
    final userName = _currentUser?.name ?? 'Người dùng';
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: primaryColor.withOpacity(0.12),
          backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : null,
          child: avatarUrl == null || avatarUrl.isEmpty
              ? Text(
                  initial,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng quan tháng $_selectedMonth/$_selectedYear',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Xin chào, $userName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _loadDashboardData,
          tooltip: 'Làm mới',
          icon: Icon(Icons.refresh_rounded, color: primaryColor),
        ),
      ],
    );
  }

  Widget _buildBalanceCard({
    required Color primaryColor,
    required double balance,
    required double totalIncome,
    required double totalExpense,
    required int transactionCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [primaryColor, const Color(0xFFFB923C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Số dư tháng này',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$transactionCount giao dịch',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _formatCurrency(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _buildMoneyMiniStat(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Tổng thu',
                  value: _formatCurrency(totalIncome),
                  color: const Color(0xFFBBF7D0),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMoneyMiniStat(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Tổng chi',
                  value: _formatCurrency(totalExpense),
                  color: const Color(0xFFFECACA),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyMiniStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(Color primaryColor) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.add_rounded,
            label: 'Nhập thu/chi',
            color: primaryColor,
            onTap: () => widget.onNavigateToTab?.call(1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.calendar_month_rounded,
            label: 'Lịch',
            color: Colors.blue,
            onTap: () => widget.onNavigateToTab?.call(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.pie_chart_rounded,
            label: 'Báo cáo',
            color: Colors.purple,
            onTap: () => widget.onNavigateToTab?.call(3),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard({
    required Color surfaceColor,
    required bool isDark,
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
    double? progress,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 156),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              fontSize: 12,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentHeader(Color primaryColor) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Giao dịch gần đây',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
        TextButton(
          onPressed: () => widget.onNavigateToTab?.call(2),
          child: Text(
            'Xem lịch',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Color surfaceColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 42,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          Text(
            'Chưa có giao dịch',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Hãy nhập khoản thu hoặc chi đầu tiên để Dashboard tự cập nhật.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => widget.onNavigateToTab?.call(1),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nhập giao dịch'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    TransactionModel transaction,
    List<CategoryModel> categories,
    Color surfaceColor,
    bool isDark,
  ) {
    final category = _findCategory(categories, transaction.categoryId);
    final isIncome = transaction.type == 'income';
    final color = category == null
        ? (isIncome ? Colors.green : Colors.redAccent)
        : _getColorFromHex(category.colorHex);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              category == null
                  ? Icons.category_outlined
                  : _getIconData(category.iconCode),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category?.name ?? 'Chưa phân loại',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    _formatDateLabel(transaction.date),
                    if (transaction.note != null &&
                        transaction.note!.isNotEmpty)
                      transaction.note!,
                  ].join(' • '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${isIncome ? '+' : '-'}${_formatCurrency(transaction.amount)}',
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.redAccent,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopCategory {
  final String name;
  final double amount;
  final int iconCode;
  final String colorHex;

  const _TopCategory({
    required this.name,
    required this.amount,
    required this.iconCode,
    required this.colorHex,
  });
}
