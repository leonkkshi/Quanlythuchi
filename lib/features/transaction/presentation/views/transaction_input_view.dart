import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../features/auth/application/services/auth_service_impl.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes/app_router.dart';
import '../../../category/application/providers/budget_provider.dart';
import '../../../category/application/providers/category_provider.dart';
import '../../../category/domain/entities/category.dart';
import '../../application/providers/transaction_provider.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (newValue.text.compareTo(oldValue.text) != 0) {
      final int selectionIndexFromTheRight =
          newValue.text.length - newValue.selection.end;
      final numberString = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (numberString.isEmpty) return newValue.copyWith(text: '');
      final number = int.parse(numberString);
      final newString = NumberFormat.decimalPattern('vi_VN').format(number).replaceAll(',', '.');
      return TextEditingValue(
        text: newString,
        selection: TextSelection.collapsed(
            offset: newString.length - selectionIndexFromTheRight),
      );
    } else {
      return newValue;
    }
  }
}

class TransactionInputView extends StatefulWidget {
  const TransactionInputView({super.key});

  @override
  State<TransactionInputView> createState() => _TransactionInputViewState();
}

class _TransactionInputViewState extends State<TransactionInputView> {
  // Tabs: 'expense' (Tiền chi) or 'income' (Tiền thu)
  String _activeTab = 'expense';
  
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _amountController = TextEditingController(text: '0');

  String? _userId;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    
    // Load categories for the logged-in user
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = Provider.of<AuthServiceImpl>(context, listen: false);
      final user = await authService.getCurrentUser();
      if (user != null && mounted) {
        _userId = user.id;
        final catProvider = Provider.of<CategoryProvider>(context, listen: false);
        await catProvider.loadCategories(user.id);
        
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
    return IconData(codePoint, fontFamily: 'IconlyLight', fontPackage: 'iconly');
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để thực hiện giao dịch.')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục giao dịch.')),
      );
      return;
    }

    final cleanAmountStr = _amountController.text.replaceAll('.', '').replaceAll(',', '');
    final double? amount = double.tryParse(cleanAmountStr);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền lớn hơn 0.')),
      );
      return;
    }

    // Kiểm tra ngân sách khi là giao dịch CHI
    if (_activeTab == 'expense') {
      final shouldProceed = await _checkBudgetAndConfirm(amount);
      if (!shouldProceed) return;
    }

    if (!mounted) return;
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final success = await txProvider.addTransaction(
      amount: amount,
      date: _selectedDate.toIso8601String().split('T')[0],
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      categoryId: _selectedCategory!.id,
      type: _activeTab,
      userId: _userId!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã nhập khoản ${_activeTab == 'expense' ? 'chi' : 'thu'} thành công!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      // Reset form
      _noteController.clear();
      _amountController.text = '0';
    }
  }

  /// Kiểm tra ngân sách và hiện dialog xác nhận nếu vượt mức.
  /// Trả về true nếu nên tiếp tục lưu, false nếu hủy.
  Future<bool> _checkBudgetAndConfirm(double newAmount) async {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);

    final period =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}';

    // Tính tổng đã chi trong tháng cho danh mục này
    final spent = txProvider.transactions
        .where((tx) =>
            tx.type == 'expense' &&
            tx.categoryId == _selectedCategory!.id &&
            tx.date.startsWith(period))
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    // Lấy ngân sách của danh mục
    final catBudget = budgetProvider.budgets
        .where((b) => b.categoryId == _selectedCategory!.id)
        .fold<double>(0, (_, b) => b.amount);

    // Lấy tổng ngân sách chung
    final totalBudget = budgetProvider.budgets
        .where((b) => b.categoryId == 'total')
        .fold<double>(0, (_, b) => b.amount);

    // Tổng đã chi trong tháng (mọi danh mục)
    final totalSpent = txProvider.transactions
        .where((tx) => tx.type == 'expense' && tx.date.startsWith(period))
        .fold<double>(0, (sum, tx) => sum + tx.amount);

    final catWillExceed = catBudget > 0 && (spent + newAmount) > catBudget;
    final totalWillExceed = totalBudget > 0 && (totalSpent + newAmount) > totalBudget;

    // ── TRƯỜNG HỢP 1: Chưa đặt ngân sách nào ─────────────────────────────────
    final noBudgetAtAll = catBudget <= 0 && totalBudget <= 0;
    if (noBudgetAtAll) {
      if (!mounted) return false;
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.orange[700],
                size: 36,
              ),
            ),
            title: const Text(
              'Chưa có ngân sách!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bạn chưa thiết lập ngân sách chi tiêu cho tháng này.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.orange.withValues(alpha: 0.08)
                        : Colors.orange.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '💡 Đặt ngân sách giúp bạn kiểm soát chi tiêu tốt hơn theo quy tắc 50/30/20.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: isDark ? Colors.orange[300] : Colors.orange[800],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.orange[300]!),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                ),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  'Bỏ qua',
                  style: TextStyle(
                      color: Colors.orange[700], fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                ),
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(
                  'Đặt ngân sách',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );
      return confirmed ?? true;
    }

    // ── TRƯỜNG HỢP 2: Không vượt ngân sách ───────────────────────────────────
    if (!catWillExceed && !totalWillExceed) return true;

    // Xây dựng nội dung cảnh báo
    final warnings = <String>[];
    if (catWillExceed) {
      final over = (spent + newAmount) - catBudget;
      warnings.add(
        '• Danh mục "${_selectedCategory!.name}":\n'
        '  Ngân sách: ${_fmtCurrency(catBudget)}  |  Đã chi: ${_fmtCurrency(spent)}\n'
        '  Vượt: ${_fmtCurrency(over)}',
      );
    }
    if (totalWillExceed) {
      final over = (totalSpent + newAmount) - totalBudget;
      warnings.add(
        '• Tổng ngân sách tháng:\n'
        '  Ngân sách: ${_fmtCurrency(totalBudget)}  |  Đã chi: ${_fmtCurrency(totalSpent)}\n'
        '  Vượt: ${_fmtCurrency(over)}',
      );
    }

    if (!mounted) return false;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: Colors.redAccent, size: 36),
          ),
          title: const Text(
            'Vượt ngân sách!',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Khoản chi này sẽ vượt giới hạn ngân sách:',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.red.withValues(alpha: 0.08)
                      : Colors.red.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  warnings.join('\n\n'),
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.6,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Bạn có muốn tiếp tục ghi khoản chi này không?',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Hủy',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Vẫn ghi',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  String _fmtCurrency(double value) {
    final n = value.toInt();
    final buffer = StringBuffer();
    final str = n.abs().toString();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    return '${value < 0 ? "-" : ""}${buffer.toString().split('').reversed.join()}đ';
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      const SizedBox(width: 48), // Balancer for Edit button
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              // Tab "Tiền chi"
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _changeTab('expense', catProvider),
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
                                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Tab "Tiền thu"
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _changeTab('income', catProvider),
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
                                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
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
                          final catProv = Provider.of<CategoryProvider>(context, listen: false);
                          context.push(AppRouter.categories).then((_) {
                            if (_userId != null) {
                              catProv.loadCategories(_userId!);
                            }
                          });
                        },
                        icon: const Icon(IconlyLight.edit),
                        color: isDark ? Colors.white : const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ),

                

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
                                      icon: const Icon(IconlyLight.arrow_left_2, size: 20),
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
                                              color: isDark ? Colors.white : const Color(0xFFB45309),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(IconlyLight.arrow_right_2, size: 20),
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
                                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
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
                                _activeTab == 'expense' ? 'Tiền chi' : 'Tiền thu',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 56,
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFBEB),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFFDE68A),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isDark ? Colors.black : const Color(0xFFFDE68A)).withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _amountController,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.right,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          CurrencyInputFormatter(),
                                        ],
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          hintText: '0',
                                        ),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'đ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF1E293B),
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
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Grid of Categories (3 columns)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: categories.length + 1, // +1 for "Chỉnh sửa"
                          itemBuilder: (context, index) {
                            if (index == categories.length) {
                              // Edit item button
                              return GestureDetector(
                                onTap: () {
                                  final catProv = Provider.of<CategoryProvider>(context, listen: false);
                                  context.push(AppRouter.categories).then((_) {
                                    if (_userId != null) {
                                      catProv.loadCategories(_userId!);
                                    }
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        IconlyLight.arrow_right_2,
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
                            final isSelected = _selectedCategory?.id == category.id;
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
                                        : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
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
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: Text(
                                        category.name,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected 
                                              ? (isDark ? Colors.white : const Color(0xFF1E293B))
                                              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
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
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          child: Text(
                            _activeTab == 'expense' ? 'Nhập khoản chi' : 'Nhập khoản thu',
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
