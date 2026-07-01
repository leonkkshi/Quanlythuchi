import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../features/auth/application/services/auth_service_impl.dart';
import '../../../category/application/providers/category_provider.dart';
import '../../application/providers/transaction_provider.dart';

class TransactionReportView extends StatefulWidget {
  const TransactionReportView({super.key});

  @override
  State<TransactionReportView> createState() => _TransactionReportViewState();
}

class _TransactionReportViewState extends State<TransactionReportView> {
  bool _isMonthly = true; // Monthly or Yearly
  bool _isExpenseTab = true; // Chi tiêu or Thu nhập

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
        Provider.of<TransactionProvider>(context, listen: false).loadTransactions(user.id);
        Provider.of<CategoryProvider>(context, listen: false).loadCategories(user.id);
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

  void _changeTimePeriod(int increment) {
    setState(() {
      if (_isMonthly) {
        _selectedMonth += increment;
        if (_selectedMonth > 12) {
          _selectedMonth = 1;
          _selectedYear += 1;
        } else if (_selectedMonth < 1) {
          _selectedMonth = 12;
          _selectedYear -= 1;
        }
      } else {
        _selectedYear += increment;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = Colors.orange[400] ?? Colors.orange;

    return Consumer2<TransactionProvider, CategoryProvider>(
      builder: (context, txProvider, catProvider, child) {
        final transactions = txProvider.transactions;
        final categories = catProvider.categories;

        // 1. Filter transactions by Period (Monthly / Yearly)
        final List<dynamic> periodTxs = transactions.where((tx) {
          final parts = tx.date.split('-'); // YYYY-MM-DD
          if (parts.length < 2) return false;
          final txYear = int.tryParse(parts[0]) ?? 0;
          final txMonth = int.tryParse(parts[1]) ?? 0;

          if (_isMonthly) {
            return txYear == _selectedYear && txMonth == _selectedMonth;
          } else {
            return txYear == _selectedYear;
          }
        }).toList();

        // 2. Sum income, expense, net total
        double periodIncome = 0;
        double periodExpense = 0;
        for (var tx in periodTxs) {
          if (tx.type == 'income') {
            periodIncome += tx.amount;
          } else {
            periodExpense += tx.amount;
          }
        }
        final periodTotal = periodIncome - periodExpense;

        // 3. Filter by selected category analysis tab (Chi tiêu or Thu nhập)
        final targetType = _isExpenseTab ? 'expense' : 'income';
        final targetTxs = periodTxs.where((tx) => tx.type == targetType).toList();
        final double totalTargetAmount = targetTxs.fold(0.0, (sum, tx) => sum + tx.amount);

        // Group by category ID
        final Map<String, double> categorySums = {};
        for (var tx in targetTxs) {
          categorySums[tx.categoryId] = (categorySums[tx.categoryId] ?? 0.0) + tx.amount;
        }

        // Convert to summaries list and sort descending
        final List<_CategorySummary> summaryList = [];
        categorySums.forEach((catId, amount) {
          final pct = totalTargetAmount > 0 ? (amount / totalTargetAmount) * 100 : 0.0;
          summaryList.add(_CategorySummary(catId, amount, pct));
        });
        summaryList.sort((a, b) => b.amount.compareTo(a.amount));

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF020617) : Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.photo_library_outlined, color: primaryColor),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng lưu báo cáo hình ảnh đang phát triển.')),
                );
              },
            ),
            title: Container(
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.all(2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _isMonthly = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isMonthly 
                            ? primaryColor 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Hàng Tháng',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _isMonthly 
                              ? Colors.white 
                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isMonthly = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: !_isMonthly 
                            ? primaryColor 
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Hàng Năm',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: !_isMonthly 
                              ? Colors.white 
                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.search_rounded, color: primaryColor),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tính năng tìm kiếm báo cáo đang phát triển.')),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // 1. Time Selector
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
                        _isMonthly
                            ? '${_selectedMonth.toString().padLeft(2, '0')}/$_selectedYear (01/${_selectedMonth.toString().padLeft(2, '0')} – ${_daysInMonth(_selectedYear, _selectedMonth).toString().padLeft(2, '0')}/${_selectedMonth.toString().padLeft(2, '0')})'
                            : 'Năm $_selectedYear (01/01 – 31/12)',
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

              // 2. Summary Boxes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Chi tiêu',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatCurrency(-periodExpense),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Thu nhập',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatCurrency(periodIncome),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Thu chi',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
                          ),
                          Text(
                            _formatCurrency(periodTotal),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Sub-tabs (Chi tiêu / Thu nhập)
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isExpenseTab = true),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _isExpenseTab ? primaryColor : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Chi tiêu',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: _isExpenseTab 
                                  ? primaryColor 
                                  : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isExpenseTab = false),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: !_isExpenseTab ? primaryColor : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Text(
                            'Thu nhập',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: !_isExpenseTab 
                                  ? primaryColor 
                                  : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. Donut Chart Section
              SizedBox(
                height: 180,
                child: summaryList.isEmpty
                    ? Center(
                        child: Text(
                          'Không có dữ liệu trong thời gian này.',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                          ),
                        ),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 60,
                              startDegreeOffset: -90,
                              sections: List.generate(summaryList.length, (index) {
                                final summary = summaryList[index];
                                final hasCategory = categories.any((c) => c.id == summary.categoryId);
                                final category = hasCategory
                                    ? categories.firstWhere((c) => c.id == summary.categoryId)
                                    : null;

                                final catColorHex = category != null ? category.colorHex : '#CBD5E1';
                                final catColor = _getColorFromHex(catColorHex);
                                final catName = category != null ? category.name : '';

                                // Only display name inside if it's the largest section (>20%)
                                final showTitle = summary.percentage > 15;

                                return PieChartSectionData(
                                  color: catColor,
                                  value: summary.amount,
                                  radius: 35,
                                  showTitle: showTitle,
                                  title: catName,
                                  titleStyle: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }),
                            ),
                          ),
                          // Display name of largest category in center if desired
                          if (summaryList.isNotEmpty)
                            Builder(
                              builder: (context) {
                                final largestSummary = summaryList.first;
                                final category = categories.firstWhere(
                                  (c) => c.id == largestSummary.categoryId,
                                  orElse: () => categories.isNotEmpty 
                                      ? categories.first 
                                      : null as dynamic,
                                );
                                final catName = category.name;
                                return Text(
                                  catName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
              ),

              const SizedBox(height: 16),

              // 5. Category List Breakdowns
              Expanded(
                child: summaryList.isEmpty
                    ? const SizedBox()
                    : ListView.separated(
                        itemCount: summaryList.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final summary = summaryList[index];
                          
                          // Lookup category info
                          final hasCategory = categories.any((c) => c.id == summary.categoryId);
                          final category = hasCategory
                              ? categories.firstWhere((c) => c.id == summary.categoryId)
                              : null;

                          final catName = category != null ? category.name : 'Chưa phân loại';
                          final catIconCode = category != null ? category.iconCode : 0xe532;
                          final catColorHex = category != null ? category.colorHex : '#94A3B8';
                          final catColor = _getColorFromHex(catColorHex);

                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: catColor.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getIconData(catIconCode),
                                color: catColor,
                                size: 22,
                              ),
                            ),
                            title: Text(
                              catName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatCurrency(summary.amount),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${summary.percentage.toStringAsFixed(1)} %',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color(0xFFCBD5E1),
                                  size: 20,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategorySummary {
  final String categoryId;
  final double amount;
  final double percentage;

  _CategorySummary(this.categoryId, this.amount, this.percentage);
}
