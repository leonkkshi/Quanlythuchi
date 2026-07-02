import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/auth/application/services/auth_service_impl.dart';
import '../../../category/application/providers/category_provider.dart';
import '../../application/providers/transaction_provider.dart';
import 'transaction_edit_view.dart';

class TransactionCalendarView extends StatefulWidget {
  const TransactionCalendarView({super.key});

  @override
  State<TransactionCalendarView> createState() =>
      _TransactionCalendarViewState();
}

class _TransactionCalendarViewState extends State<TransactionCalendarView> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _selectedDay = now.day;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = Provider.of<AuthServiceImpl>(context, listen: false);
      final user = await authService.getCurrentUser();
      if (user != null && mounted) {
        Provider.of<TransactionProvider>(
          context,
          listen: false,
        ).loadTransactions(user.id);
        Provider.of<CategoryProvider>(
          context,
          listen: false,
        ).loadCategories(user.id);
      }
    });
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Th 2';
      case 2:
        return 'Th 3';
      case 3:
        return 'Th 4';
      case 4:
        return 'Th 5';
      case 5:
        return 'Th 6';
      case 6:
        return 'Th 7';
      case 7:
        return 'CN';
      default:
        return '';
    }
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

  String _formatAmountOnly(double value) {
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
    return formatted;
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

  void _changeMonth(int increment) {
    setState(() {
      _selectedMonth += increment;
      if (_selectedMonth > 12) {
        _selectedMonth = 1;
        _selectedYear += 1;
      } else if (_selectedMonth < 1) {
        _selectedMonth = 12;
        _selectedYear -= 1;
      }
      // Update selected day to fit new month
      final maxDays = _daysInMonth(_selectedYear, _selectedMonth);
      if (_selectedDay > maxDays) {
        _selectedDay = maxDays;
      }
    });
  }

  void _deleteTx(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa giao dịch này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).deleteTransaction(id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa giao dịch thành công!')),
        );
      }
    }
  }

  void _showSearchDialog(TransactionProvider txProvider) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Tìm kiếm giao dịch'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Nhập ghi chú hoặc số tiền',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                txProvider.clearSearch();
                Navigator.pop(context);
              },
              child: const Text('Hiện tất cả'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                txProvider.searchTransactions(controller.text);

                Navigator.pop(context);
              },
              child: const Text('Tìm'),
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

    return Consumer2<TransactionProvider, CategoryProvider>(
      builder: (context, txProvider, catProvider, child) {
        final transactions = txProvider.transactions;
        final categories = catProvider.categories;

        // Build grid of days
        final firstDayOfMonth = DateTime(_selectedYear, _selectedMonth, 1);
        final firstWeekday = firstDayOfMonth.weekday; // 1 = Mon, ..., 7 = Sun
        final prevMonthDaysCount = firstWeekday - 1;

        final cells = <DateTime>[];
        // Previous month padding days
        final prevMonthEnd = DateTime(_selectedYear, _selectedMonth, 0);
        for (int i = prevMonthDaysCount - 1; i >= 0; i--) {
          cells.add(
            DateTime(
              prevMonthEnd.year,
              prevMonthEnd.month,
              prevMonthEnd.day - i,
            ),
          );
        }

        // Current month days
        final currentMonthDays = _daysInMonth(_selectedYear, _selectedMonth);
        for (int i = 1; i <= currentMonthDays; i++) {
          cells.add(DateTime(_selectedYear, _selectedMonth, i));
        }

        // Next month padding days to fill grid of 35 or 42 cells
        final totalCells = cells.length <= 35 ? 35 : 42;
        int nextMonthDay = 1;
        while (cells.length < totalCells) {
          cells.add(
            DateTime(_selectedYear, _selectedMonth + 1, nextMonthDay++),
          );
        }

        // Filter transactions for currently selected day
        final selectedDateStr =
            "${_selectedYear.toString().padLeft(4, '0')}-${_selectedMonth.toString().padLeft(2, '0')}-${_selectedDay.toString().padLeft(2, '0')}";
        final selectedDayTxs = transactions
            .where((tx) => tx.date == selectedDateStr)
            .toList();

        // Calculate sums for the selected day
        double dayIncome = 0;
        double dayExpense = 0;
        for (var tx in selectedDayTxs) {
          if (tx.type == 'income') {
            dayIncome += tx.amount;
          } else {
            dayExpense += tx.amount;
          }
        }
        final dayTotal = dayIncome - dayExpense;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF020617) : Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
              'Lịch',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded, color: Colors.orange),
                onPressed: () {
                  _showSearchDialog(txProvider);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // 1. Month Selector
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFFEF3C7),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF94A3B8),
                        ),
                        onPressed: () => _changeMonth(-1),
                      ),
                      Text(
                        '${_selectedMonth.toString().padLeft(2, '0')}/$_selectedYear (01/${_selectedMonth.toString().padLeft(2, '0')} – ${currentMonthDays.toString().padLeft(2, '0')}/${_selectedMonth.toString().padLeft(2, '0')})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF78350F),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF94A3B8),
                        ),
                        onPressed: () => _changeMonth(1),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Weekdays Header
              Container(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: List.generate(7, (index) {
                    final dayLabel = _getWeekdayName(index + 1);
                    Color textColor = isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B);
                    if (index == 5) {
                      textColor = Colors.blue[400] ?? Colors.blue;
                    } else if (index == 6) {
                      textColor = Colors.red[400] ?? Colors.red;
                    }

                    return Expanded(
                      child: Text(
                        dayLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: textColor,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // 3. Calendar Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.25,
                ),
                itemCount: totalCells,
                itemBuilder: (context, index) {
                  final cell = cells[index];
                  final isCurrentMonth =
                      cell.month == _selectedMonth &&
                      cell.year == _selectedYear;
                  final isSelected = cell.day == _selectedDay && isCurrentMonth;

                  // Format cell date string to lookup transactions
                  final cellDateStr =
                      "${cell.year.toString().padLeft(4, '0')}-${cell.month.toString().padLeft(2, '0')}-${cell.day.toString().padLeft(2, '0')}";
                  final cellTxs = transactions
                      .where((tx) => tx.date == cellDateStr)
                      .toList();

                  // Sum expense & income for this day cell
                  double cellExpense = 0;
                  double cellIncome = 0;
                  for (var tx in cellTxs) {
                    if (tx.type == 'expense') {
                      cellExpense += tx.amount;
                    } else {
                      cellIncome += tx.amount;
                    }
                  }

                  // Determine display color for day number
                  Color dayColor = isDark
                      ? Colors.white
                      : const Color(0xFF1E293B);
                  if (!isCurrentMonth) {
                    dayColor = isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1);
                  } else {
                    final weekday = cell.weekday;
                    if (weekday == 6) {
                      dayColor = Colors.blue[400] ?? Colors.blue;
                    } else if (weekday == 7) {
                      dayColor = Colors.red[400] ?? Colors.red;
                    }
                  }

                  return GestureDetector(
                    onTap: () {
                      if (isCurrentMonth) {
                        setState(() {
                          _selectedDay = cell.day;
                        });
                      } else {
                        // Switch to that month and select day
                        setState(() {
                          _selectedYear = cell.year;
                          _selectedMonth = cell.month;
                          _selectedDay = cell.day;
                        });
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                  ? const Color(0xFF78350F).withOpacity(0.3)
                                  : const Color(0xFFFFFBEB))
                            : Colors.transparent,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          width: 0.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${cell.day}',
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                              color: dayColor,
                            ),
                          ),
                          if (cellExpense > 0)
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                _formatAmountOnly(cellExpense),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                            )
                          else if (cellIncome > 0)
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                _formatAmountOnly(cellIncome),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // 4. Daily Summary Info Row
              Container(
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Thu nhập',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(dayIncome),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Chi tiêu',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(dayExpense),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          'Tổng',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(dayTotal),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: dayTotal >= 0
                                ? Colors.blueAccent
                                : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 5. Selected Day Transactions List Header
              Container(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF8FAFC),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDay.toString().padLeft(2, '0')}/${_selectedMonth.toString().padLeft(2, '0')}/$_selectedYear (${_getWeekdayName(DateTime(_selectedYear, _selectedMonth, _selectedDay).weekday)})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      _formatCurrency(dayTotal),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: dayTotal >= 0
                            ? Colors.blueAccent
                            : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),

              // 6. Selected Day Transactions List
              Expanded(
                child: selectedDayTxs.isEmpty
                    ? Center(
                        child: Text(
                          'Không có giao dịch nào trong ngày này.',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: selectedDayTxs.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final tx = selectedDayTxs[index];

                          // Lookup category info
                          final hasCategory = categories.any(
                            (c) => c.id == tx.categoryId,
                          );
                          final category = hasCategory
                              ? categories.firstWhere(
                                  (c) => c.id == tx.categoryId,
                                )
                              : null;

                          final catName = category != null
                              ? category.name
                              : 'Chưa phân loại';
                          final catIconCode = category != null
                              ? category.iconCode
                              : 0xe532;
                          final catColorHex = category != null
                              ? category.colorHex
                              : '#94A3B8';
                          final catColor = _getColorFromHex(catColorHex);

                          return ListTile(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditTransactionView(transaction: tx),
                                ),
                              );

                              if (result == true && context.mounted) {
                                final authService =
                                    Provider.of<AuthServiceImpl>(
                                      context,
                                      listen: false,
                                    );

                                final user = await authService.getCurrentUser();

                                if (user != null) {
                                  await Provider.of<TransactionProvider>(
                                    context,
                                    listen: false,
                                  ).loadTransactions(user.id);
                                }
                              }
                            },

                            onLongPress: () => _deleteTx(context, tx.id),
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
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                            subtitle: tx.note != null && tx.note!.isNotEmpty
                                ? Text(
                                    tx.note!,
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF94A3B8),
                                      fontSize: 12,
                                    ),
                                  )
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatCurrency(tx.amount),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: tx.type == 'income'
                                        ? Colors.blueAccent
                                        : const Color(0xFF334155),
                                  ),
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
