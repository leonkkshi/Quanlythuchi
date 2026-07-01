import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/auth/application/services/auth_service_impl.dart';
import '../../../transaction/application/providers/transaction_provider.dart';
import '../../application/providers/category_provider.dart';
import '../../application/providers/budget_provider.dart';

class BudgetView extends StatefulWidget {
  const BudgetView({super.key});

  @override
  State<BudgetView> createState() => _BudgetViewState();
}

class _BudgetViewState extends State<BudgetView> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = Provider.of<AuthServiceImpl>(context, listen: false);
      final user = await authService.getCurrentUser();
      if (user != null && mounted) {
        final period = '$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}';
        Provider.of<TransactionProvider>(context, listen: false).loadTransactions(user.id);
        Provider.of<CategoryProvider>(context, listen: false).loadCategories(user.id);
        Provider.of<BudgetProvider>(context, listen: false).loadBudgets(user.id, period);
      }
    });
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  String _formatCurrency(double value) {
    final cleanValue = value.toInt();
    final buffer = StringBuffer();
    final str = cleanValue.abs().toString();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write(',');
      }
    }
    final formatted = buffer.toString().split('').reversed.join();
    return '${value < 0 ? "-" : ""}$formattedđ';
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

  void _changeTimePeriod(int increment) async {
    setState(() {
      _selectedMonth += increment;
      if (_selectedMonth > 12) {
        _selectedMonth = 1;
        _selectedYear += 1;
      } else if (_selectedMonth < 1) {
        _selectedMonth = 12;
        _selectedYear -= 1;
      }
    });

    final authService = Provider.of<AuthServiceImpl>(context, listen: false);
    final user = await authService.getCurrentUser();
    if (user != null && mounted) {
      final period = '$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}';
      Provider.of<BudgetProvider>(context, listen: false).loadBudgets(user.id, period);
    }
  }

  void _showSetBudgetDialog(
    BuildContext context, {
    required String categoryId,
    required String categoryName,
    required double currentAmount,
  }) {
    final controller = TextEditingController(
      text: currentAmount > 0 ? currentAmount.toInt().toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Text(
            'Đặt ngân sách\n$categoryName',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Nhập số tiền hạn mức (đ)',
              suffixText: 'đ',
              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            ),
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('HỦY', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800] ?? Colors.orange,
                minimumSize: const Size(80, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final text = controller.text.trim();
                final amount = double.tryParse(text) ?? 0.0;

                final authService = Provider.of<AuthServiceImpl>(context, listen: false);
                final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                final user = await authService.getCurrentUser();
                if (user != null) {
                  final period = '$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}';
                  await budgetProvider.setBudget(
                    userId: user.id,
                    categoryId: categoryId,
                    period: period,
                    amount: amount,
                  );
                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('Đã cập nhật ngân sách thành công!')),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = Colors.orange[800] ?? Colors.orange;

    return Consumer3<TransactionProvider, CategoryProvider, BudgetProvider>(
      builder: (context, txProvider, catProvider, budgetProvider, child) {
        final transactions = txProvider.transactions;
        final categories = catProvider.categories.where((c) => c.type == 'expense').toList();
        final budgets = budgetProvider.budgets;

        // Filter transactions for current period
        final List<dynamic> periodExpenseTxs = transactions.where((tx) {
          final parts = tx.date.split('-');
          if (parts.length < 2) return false;
          final txYear = int.tryParse(parts[0]) ?? 0;
          final txMonth = int.tryParse(parts[1]) ?? 0;
          return tx.type == 'expense' && txYear == _selectedYear && txMonth == _selectedMonth;
        }).toList();

        // Calculate actual expense sums per category
        final Map<String, double> categoryExpenses = {};
        double totalExpense = 0;
        for (var tx in periodExpenseTxs) {
          categoryExpenses[tx.categoryId] = (categoryExpenses[tx.categoryId] ?? 0.0) + tx.amount;
          totalExpense += tx.amount;
        }

        // --- Calculate Total Budget stats ---
        final totalBudgetModel = budgets.any((b) => b.categoryId == 'total')
            ? budgets.firstWhere((b) => b.categoryId == 'total')
            : null;
        final double totalBudgetAmount = totalBudgetModel?.amount ?? 0.0;
        final bool totalIsSet = totalBudgetAmount > 0;
        final double totalRemaining = totalIsSet ? (totalBudgetAmount - totalExpense) : -totalExpense;
        final double totalPercentage = totalIsSet 
            ? (totalExpense / totalBudgetAmount) * 100 
            : (totalExpense > 0 ? 100.0 : 0.0);
        final double totalProgress = totalIsSet 
            ? (totalExpense / totalBudgetAmount).clamp(0.0, 1.0) 
            : (totalExpense > 0 ? 1.0 : 0.0);

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF020617) : Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.photo_library_outlined, color: primaryColor),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng lưu hình ảnh đang phát triển.')),
                );
              },
            ),
            title: const Text('Ngân sách'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.tune_rounded, color: primaryColor),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tính năng lọc đang phát triển.')),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Month Selector Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFFEF3C7),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF94A3B8)),
                        onPressed: () => _changeTimePeriod(-1),
                      ),
                      Text(
                        '${_selectedMonth.toString().padLeft(2, '0')}/$_selectedYear (01/${_selectedMonth.toString().padLeft(2, '0')} – ${_daysInMonth(_selectedYear, _selectedMonth).toString().padLeft(2, '0')}/${_selectedMonth.toString().padLeft(2, '0')})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white : const Color(0xFF78350F),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                        onPressed: () => _changeTimePeriod(1),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Budgets List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    // Total Budget Item
                    InkWell(
                      onTap: () => _showSetBudgetDialog(
                        context,
                        categoryId: 'total',
                        categoryName: 'Tổng ngân sách',
                        currentAmount: totalBudgetAmount,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tổng ngân sách',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      totalRemaining == 0 && !totalIsSet
                                          ? 'Chưa đặt'
                                          : 'Còn lại: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                    if (totalRemaining != 0 || totalIsSet)
                                      Text(
                                        _formatCurrency(totalRemaining),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: totalRemaining < 0 ? Colors.redAccent : Colors.green,
                                        ),
                                      ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Color(0xFFCBD5E1),
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: totalProgress,
                                      minHeight: 8,
                                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${totalPercentage.toStringAsFixed(0)} %',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  totalIsSet
                                      ? 'Ngân sách ${_formatCurrency(totalBudgetAmount)}'
                                      : 'Ngân sách Chưa đặt',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                  ),
                                ),
                                Text(
                                  'Chi tiêu ${_formatCurrency(totalExpense)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 24, thickness: 1),

                    // Individual Categories Budgets
                    ...categories.map((cat) {
                      final catExpense = categoryExpenses[cat.id] ?? 0.0;
                      
                      // Look up budget
                      final budgetModel = budgets.any((b) => b.categoryId == cat.id)
                          ? budgets.firstWhere((b) => b.categoryId == cat.id)
                          : null;
                      final double budgetAmount = budgetModel?.amount ?? 0.0;
                      final bool isSet = budgetAmount > 0;
                      final double remaining = isSet ? (budgetAmount - catExpense) : -catExpense;
                      final double percentage = isSet 
                          ? (catExpense / budgetAmount) * 100 
                          : (catExpense > 0 ? 100.0 : 0.0);
                      final double progress = isSet 
                          ? (catExpense / budgetAmount).clamp(0.0, 1.0) 
                          : (catExpense > 0 ? 1.0 : 0.0);

                      final catColor = _getColorFromHex(cat.colorHex);

                      return InkWell(
                        onTap: () => _showSetBudgetDialog(
                          context,
                          categoryId: cat.id,
                          categoryName: cat.name,
                          currentAmount: budgetAmount,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getIconData(cat.iconCode),
                                    color: catColor,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    cat.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    remaining == 0 && !isSet
                                        ? 'Chưa đặt'
                                        : 'Còn lại: ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                  if (remaining != 0 || isSet)
                                    Text(
                                      _formatCurrency(remaining),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: remaining < 0 ? Colors.redAccent : Colors.green,
                                      ),
                                    ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFFCBD5E1),
                                    size: 20,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 8,
                                        backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                        valueColor: AlwaysStoppedAnimation<Color>(catColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${percentage.toStringAsFixed(0)} %',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isSet
                                        ? 'Ngân sách ${_formatCurrency(budgetAmount)}'
                                        : 'Ngân sách Chưa đặt',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                  Text(
                                    'Chi tiêu ${_formatCurrency(catExpense)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
