import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import '../../application/providers/category_provider.dart';

class CreateCategoryPage extends StatefulWidget {
  final String type; // 'expense' or 'income'
  final String userId;

  const CreateCategoryPage({
    super.key,
    required this.type,
    required this.userId,
  });

  @override
  State<CreateCategoryPage> createState() => _CreateCategoryPageState();
}

class _CreateCategoryPageState extends State<CreateCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  int _selectedIconCode = IconlyLight.bag.codePoint; // Default shopping cart
  String _selectedColorHex = '#FDE047'; // Default yellow

  final List<int> _iconOptions = [
    IconlyLight.bag.codePoint,
    IconlyLight.buy.codePoint,
    IconlyLight.camera.codePoint,
    IconlyLight.bookmark.codePoint,
    IconlyLight.call.codePoint,
    IconlyLight.chat.codePoint,
    IconlyLight.calendar.codePoint,
    IconlyLight.discovery.codePoint,
    IconlyLight.document.codePoint,
    IconlyLight.edit.codePoint,
    IconlyLight.folder.codePoint,
    IconlyLight.game.codePoint,
    IconlyLight.graph.codePoint,
    IconlyLight.heart.codePoint,
    IconlyLight.home.codePoint,
    IconlyLight.image.codePoint,
  ];

  final List<String> _colorOptions = [
    '#FDE047', '#FFC0AD', '#F87171', '#FBCFE8', '#F5D0FE',
    '#F97316', '#EF4444', '#EC4899', '#D946EF', '#C084FC',
    '#B45309', '#991B1B', '#9D174D', '#86198F', '#6B21A8',
    '#FEF08A', '#E2F343', '#D9F99D', '#A7F3D0', '#67E8F9',
    '#FACC15', '#84CC16', '#22C55E', '#14B8A6', '#06B6D4',
    '#A16207', '#4D7C0F', '#15803D', '#0F766E', '#0891B2',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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

  void _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<CategoryProvider>(context, listen: false);
    final success = await provider.addCategory(
      name: _nameController.text.trim(),
      type: widget.type,
      iconCode: _selectedIconCode,
      colorHex: _selectedColorHex,
      userId: widget.userId,
    );

    if (success && context.mounted) {
      Navigator.pop(context, true);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra khi tạo danh mục.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = Colors.orange[400] ?? Colors.orange;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(IconlyLight.arrow_left_2, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tạo mới',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Tên Field
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 60,
                            child: Text(
                              'Tên',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: 'Vui lòng nhập vào tên đề mục',
                                hintStyle: TextStyle(
                                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              style: const TextStyle(fontSize: 16),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Tên không được bỏ trống';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),

                      // 2. Biểu tượng Section
                      const Text(
                        'Biểu tượng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: _iconOptions.length,
                        itemBuilder: (context, index) {
                          final iconCode = _iconOptions[index];
                          final icon = _getIconData(iconCode);
                          final isSelected = _selectedIconCode == iconCode;
                          final activeColor = _getColorFromHex(_selectedColorHex);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIconCode = iconCode;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? activeColor.withOpacity(isDark ? 0.2 : 0.08) 
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected 
                                      ? activeColor 
                                      : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                icon,
                                size: 24,
                                color: isSelected 
                                    ? activeColor 
                                    : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // 3. Màu sắc Section
                      const Text(
                        'Màu sắc',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.0,
                        ),
                        itemCount: _colorOptions.length,
                        itemBuilder: (context, index) {
                          final colorHex = _colorOptions[index];
                          final color = _getColorFromHex(colorHex);
                          final isSelected = _selectedColorHex == colorHex;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColorHex = colorHex;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(6),
                                border: isSelected
                                    ? Border.all(
                                        color: isDark ? Colors.white : Colors.black,
                                        width: 2.5,
                                      )
                                    : Border.all(
                                        color: Colors.black.withOpacity(0.08),
                                        width: 1.0,
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            
            // 4. Nút Lưu ở dưới cùng
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _save(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2B880), // Peach-orange matching screenshot
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Lưu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
