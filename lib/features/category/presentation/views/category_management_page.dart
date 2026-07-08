import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/auth/application/services/auth_service_impl.dart';
import '../../application/providers/category_provider.dart';
import '../../domain/entities/category.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  // Tabs: 'expense' (Chi tiêu) or 'income' (Thu nhập)
  String _activeTab = 'expense';
  bool _isEditMode = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = Provider.of<AuthServiceImpl>(context, listen: false);
      final user = await authService.getCurrentUser();
      if (user != null && mounted) {
        _userId = user.id;
        Provider.of<CategoryProvider>(context, listen: false).loadCategories(user.id);
      }
    });
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

  void _navigateToAddCategory(BuildContext context, CategoryProvider provider) async {
    if (_userId == null) return;
    
    final success = await Navigator.pushNamed(
      context,
      '/create-category',
      arguments: {'type': _activeTab, 'userId': _userId},
    );
    
    if (success == true && context.mounted) {
      provider.loadCategories(_userId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm danh mục mới thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _deleteCategory(BuildContext context, Category category, CategoryProvider provider) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa danh mục "${category.name}"?'),
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

    if (confirm == true && context.mounted) {
      final success = await provider.deleteCategory(category.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa danh mục "${category.name}"')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = Colors.orange[800] ?? Colors.orange;

    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        final categories = _activeTab == 'expense'
            ? provider.expenseCategories
            : provider.incomeCategories;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _activeTab = 'expense'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: _activeTab == 'expense' ? primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'Chi tiêu',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _activeTab == 'expense'
                                  ? Colors.white
                                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _activeTab = 'income'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: _activeTab == 'income' ? primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'Thu nhập',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _activeTab == 'income'
                                  ? Colors.white
                                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isEditMode = !_isEditMode;
                  });
                },
                child: Text(
                  _isEditMode ? 'Hoàn tất' : 'Chỉnh sửa',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  children: [
                    // "Thêm danh mục" Button Row
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add_rounded, color: primaryColor, size: 20),
                        ),
                        title: Text(
                          'Thêm danh mục',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
                        onTap: () => _navigateToAddCategory(context, provider),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Categories List Group
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      color: isDark ? const Color(0xFF0F172A) : Colors.white,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, indent: 56),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final color = _getColorFromHex(category.colorHex);

                          return ListTile(
                            leading: Icon(
                              _getIconData(category.iconCode),
                              color: color,
                              size: 24,
                            ),
                            title: Text(
                              category.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            trailing: _isEditMode
                                ? IconButton(
                                    icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.redAccent),
                                    onPressed: () => _deleteCategory(context, category, provider),
                                  )
                                : const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
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

