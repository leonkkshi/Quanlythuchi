import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../features/auth/application/services/auth_service_impl.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../category/application/providers/category_provider.dart';
import '../../../category/domain/entities/category.dart';
import '../../application/providers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';

class EditTransactionView extends StatefulWidget {
  final TransactionModel transaction;

  const EditTransactionView({super.key, required this.transaction});

  @override
  State<EditTransactionView> createState() => _EditTransactionViewState();
}

class _EditTransactionViewState extends State<EditTransactionView> {
  // Tabs: 'expense' (Tiền chi) or 'income' (Tiền thu)
  String _activeTab = 'expense';

  DateTime _selectedDate = DateTime.now();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _amountController = TextEditingController(
    text: '0',
  );

  String? _userId;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();

    _activeTab = widget.transaction.type;
    _selectedDate = DateTime.parse(widget.transaction.date);
    _noteController.text = widget.transaction.note ?? '';
    _amountController.text = widget.transaction.amount.toString();
    _amountController.addListener(_onAmountChanged);

    // Load categories for the logged-in user
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = Provider.of<AuthServiceImpl>(context, listen: false);
      final user = await authService.getCurrentUser();
      if (user != null && mounted) {
        _userId = user.id;
        final catProvider = Provider.of<CategoryProvider>(
          context,
          listen: false,
        );
        await catProvider.loadCategories(user.id);

        final allCategories = [
          ...catProvider.expenseCategories,
          ...catProvider.incomeCategories,
        ];

        try {
          _selectedCategory = allCategories.firstWhere(
            (c) => c.id == widget.transaction.categoryId,
          );
        } catch (_) {}

        // Auto-select first category if available
        _autoSelectFirstCategory(catProvider);
      }
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    // Avoid leaving empty value
    if (_amountController.text.isEmpty) {
      _amountController.value = const TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: 1),
      );
    }
  }

  void _autoSelectFirstCategory(CategoryProvider provider) {
    final list = _activeTab == 'expense'
        ? provider.expenseCategories
        : provider.incomeCategories;
    if (list.isNotEmpty) {
      setState(() {
        _selectedCategory = list.first;
      });
    } else {
      setState(() {
        _selectedCategory = null;
      });
    }
  }

  void _changeTab(String tab, CategoryProvider provider) {
    if (_activeTab == tab) return;
    setState(() {
      _activeTab = tab;
    });
    _autoSelectFirstCategory(provider);
  }

  // Format date to: 01/07/2026 (Th 4)
  String _formatDate(DateTime date) {
    final dayStr = date.day.toString().padLeft(2, '0');
    final monthStr = date.month.toString().padLeft(2, '0');
    final yearStr = date.year.toString();

    final weekdayNames = {
      DateTime.monday: 'Th 2',
      DateTime.tuesday: 'Th 3',
      DateTime.wednesday: 'Th 4',
      DateTime.thursday: 'Th 5',
      DateTime.friday: 'Th 6',
      DateTime.saturday: 'Th 7',
      DateTime.sunday: 'CN',
    };

    final weekdayStr = weekdayNames[date.weekday] ?? '';
    return '$dayStr/$monthStr/$yearStr ($weekdayStr)';
  }

  void _adjustDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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

  void _submit() async {
    if (_userId == null) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn danh mục')));
      return;
    }

    final amount = double.tryParse(_amountController.text);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }

    final updatedTransaction = TransactionModel(
      id: widget.transaction.id,
      amount: amount,
      date: _selectedDate.toIso8601String().split('T')[0],
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      categoryId: _selectedCategory!.id,
      type: _activeTab,
      userId: _userId!,
    );

    final provider = Provider.of<TransactionProvider>(context, listen: false);

    final success = await provider.updateTransaction(updatedTransaction);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật giao dịch thành công'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = Colors.orange[800] ?? Colors.orange;

    return Consumer<CategoryProvider>(
      builder: (context, catProvider, child) {
        final categories = _activeTab == 'expense'
            ? catProvider.expenseCategories
            : catProvider.incomeCategories;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF020617) : Colors.white,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Top Tabs (Tiền chi / Tiền thu)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 48), // Balancer for Edit button
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              // Tab "Tiền chi"
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _changeTab('expense', catProvider),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _activeTab == 'expense'
                                          ? primaryColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Tiền chi',
                                      style: TextStyle(
                                        color: _activeTab == 'expense'
                                            ? Colors.white
                                            : (isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF64748B)),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Tab "Tiền thu"
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      _changeTab('income', catProvider),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _activeTab == 'income'
                                          ? primaryColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Tiền thu',
                                      style: TextStyle(
                                        color: _activeTab == 'income'
                                            ? Colors.white
                                            : (isDark
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF64748B)),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final catProv = Provider.of<CategoryProvider>(
                            context,
                            listen: false,
                          );
                          Navigator.pushNamed(
                            context,
                            AppRoutes.categories,
                          ).then((_) {
                            if (_userId != null) {
                              catProv.loadCategories(_userId!);
                            }
                          });
                        },
                        icon: const Icon(Icons.edit_outlined),
                        color: isDark ? Colors.white : const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // 2. Form Inputs (Date, Note, Amount)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Date picker row
                        Row(
                          children: [
                            const SizedBox(
                              width: 80,
                              child: Text(
                                'Ngày',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 44,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.chevron_left_rounded,
                                        size: 20,
                                      ),
                                      onPressed: () => _adjustDate(-1),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _selectDate(context),
                                        child: Center(
                                          child: Text(
                                            _formatDate(_selectedDate),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFFB45309),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.chevron_right_rounded,
                                        size: 20,
                                      ),
                                      onPressed: () => _adjustDate(1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Note row
                        Row(
                          children: [
                            const SizedBox(
                              width: 80,
                              child: Text(
                                'Ghi chú',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _noteController,
                                decoration: InputDecoration(
                                  hintText: 'Chưa nhập vào',
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF475569)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Amount row
                        Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                _activeTab == 'expense'
                                    ? 'Tiền chi'
                                    : 'Tiền thu',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
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
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _amountController,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.right,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'đ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Category Section
                        Text(
                          'Danh mục',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Grid of Categories (3 columns)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1.1,
                              ),
                          itemCount:
                              categories.length + 1, // +1 for "Chỉnh sửa"
                          itemBuilder: (context, index) {
                            if (index == categories.length) {
                              // Edit item button
                              return GestureDetector(
                                onTap: () {
                                  final catProv = Provider.of<CategoryProvider>(
                                    context,
                                    listen: false,
                                  );
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.categories,
                                  ).then((_) {
                                    if (_userId != null) {
                                      catProv.loadCategories(_userId!);
                                    }
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        size: 24,
                                        color: Color(0xFF94A3B8),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Chỉnh sửa >',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final category = categories[index];
                            final isSelected =
                                _selectedCategory?.id == category.id;
                            final color = _getColorFromHex(category.colorHex);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? color.withOpacity(isDark ? 0.2 : 0.08)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? color
                                        : (isDark
                                              ? const Color(0xFF334155)
                                              : const Color(0xFFE2E8F0)),
                                    width: isSelected ? 2.0 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getIconData(category.iconCode),
                                      size: 26,
                                      color: color,
                                    ),
                                    const SizedBox(height: 6),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                      ),
                                      child: Text(
                                        category.name,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                          color: isSelected
                                              ? (isDark
                                                    ? Colors.white
                                                    : const Color(0xFF1E293B))
                                              : (isDark
                                                    ? const Color(0xFF94A3B8)
                                                    : const Color(0xFF64748B)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // Large Orange Submit Button
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _activeTab == 'expense'
                                ? 'Cập nhật khoản chi'
                                : 'Cập nhật khoản thu',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
