import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import '../../application/providers/category_provider.dart';

// ─── Dữ liệu icon với nhãn ────────────────────────────────────────────────────
class _IconOption {
  final int codePoint;
  final String label;
  const _IconOption(this.codePoint, this.label);
}

// ─── Widget ───────────────────────────────────────────────────────────────────
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

  int _selectedIconCode = IconlyLight.bag.codePoint;
  String _selectedColorHex = '#FDE047';

  // ── Danh sách icon đầy đủ ──────────────────────────────────────────────────
  final List<_IconOption> _iconOptions = [
    // Mua sắm & Ăn uống
    _IconOption(IconlyLight.bag.codePoint, 'Túi'),
    _IconOption(IconlyLight.buy.codePoint, 'Mua sắm'),
    _IconOption(IconlyLight.wallet.codePoint, 'Ví'),
    _IconOption(IconlyLight.ticket_star.codePoint, 'Phiếu'),

    // Nhà cửa & Đi lại
    _IconOption(IconlyLight.home.codePoint, 'Nhà'),
    _IconOption(IconlyLight.location.codePoint, 'Địa điểm'),
    _IconOption(IconlyLight.send.codePoint, 'Đi lại'),
    _IconOption(IconlyLight.discovery.codePoint, 'Khám phá'),

    // Sức khỏe & Thể thao
    _IconOption(IconlyLight.heart.codePoint, 'Sức khỏe'),
    _IconOption(IconlyLight.activity.codePoint, 'Hoạt động'),
    _IconOption(IconlyLight.game.codePoint, 'Thể thao'),
    _IconOption(IconlyLight.shield_done.codePoint, 'Bảo hiểm'),

    // Học tập & Công việc
    _IconOption(IconlyLight.document.codePoint, 'Tài liệu'),
    _IconOption(IconlyLight.edit.codePoint, 'Ghi chú'),
    _IconOption(IconlyLight.folder.codePoint, 'Thư mục'),
    _IconOption(IconlyLight.paper.codePoint, 'Giấy tờ'),

    // Giải trí & Xã hội
    _IconOption(IconlyLight.camera.codePoint, 'Camera'),
    _IconOption(IconlyLight.image.codePoint, 'Ảnh'),
    _IconOption(IconlyLight.video.codePoint, 'Video'),
    _IconOption(IconlyLight.bookmark.codePoint, 'Đánh dấu'),

    // Giao tiếp
    _IconOption(IconlyLight.call.codePoint, 'Điện thoại'),
    _IconOption(IconlyLight.chat.codePoint, 'Tin nhắn'),
    _IconOption(IconlyLight.message.codePoint, 'Email'),
    _IconOption(IconlyLight.notification.codePoint, 'Thông báo'),

    // Tài chính & Quản lý
    _IconOption(IconlyLight.graph.codePoint, 'Biểu đồ'),
    _IconOption(IconlyLight.chart.codePoint, 'Thống kê'),
    _IconOption(IconlyLight.calendar.codePoint, 'Lịch'),
    _IconOption(IconlyLight.time_circle.codePoint, 'Thời gian'),

    // Người dùng & Cài đặt
    _IconOption(IconlyLight.profile.codePoint, 'Hồ sơ'),
    _IconOption(IconlyLight.add_user.codePoint, 'Thêm'),
    _IconOption(IconlyLight.setting.codePoint, 'Cài đặt'),
    _IconOption(IconlyLight.filter.codePoint, 'Lọc'),

    // Khác
    _IconOption(IconlyLight.star.codePoint, 'Yêu thích'),
    _IconOption(IconlyLight.info_circle.codePoint, 'Thông tin'),
    _IconOption(IconlyLight.lock.codePoint, 'Bảo mật'),
    _IconOption(IconlyLight.work.codePoint, 'Công việc'),
  ];

  // ── Màu sắc ────────────────────────────────────────────────────────────────
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
    final primaryColor = Colors.orange[700] ?? Colors.orange;
    final selectedColor = _getColorFromHex(_selectedColorHex);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(IconlyLight.arrow_left_2, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.type == 'expense' ? 'Tạo danh mục chi' : 'Tạo danh mục thu',
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

                      // ── PREVIEW ─────────────────────────────────────────────
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: selectedColor.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                            border: Border.all(color: selectedColor, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: selectedColor.withValues(alpha: 0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getIconData(_selectedIconCode),
                            size: 40,
                            color: selectedColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selectedColor,
                          ),
                          child: Text(
                            _iconOptions
                                .firstWhere(
                                  (o) => o.codePoint == _selectedIconCode,
                                  orElse: () => const _IconOption(0, ''),
                                )
                                .label,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── TÊN DANH MỤC ────────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(IconlyLight.edit, color: selectedColor, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: 'Tên danh mục...',
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF475569)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                                ),
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
                      ),

                      const SizedBox(height: 28),

                      // ── ICON ────────────────────────────────────────────────
                      _SectionTitle(label: 'Biểu tượng', isDark: isDark),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: _iconOptions.length,
                        itemBuilder: (context, index) {
                          final opt = _iconOptions[index];
                          final isSelected = _selectedIconCode == opt.codePoint;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedIconCode = opt.codePoint),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? selectedColor.withValues(alpha: isDark ? 0.22 : 0.12)
                                    : (isDark
                                        ? const Color(0xFF0F172A)
                                        : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? selectedColor
                                      : (isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFE2E8F0)),
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: selectedColor.withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                    : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getIconData(opt.codePoint),
                                    size: 24,
                                    color: isSelected
                                        ? selectedColor
                                        : (isDark
                                            ? const Color(0xFF64748B)
                                            : const Color(0xFF94A3B8)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    opt.label,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? selectedColor
                                          : (isDark
                                              ? const Color(0xFF64748B)
                                              : const Color(0xFF94A3B8)),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 28),

                      // ── MÀU SẮC ─────────────────────────────────────────────
                      _SectionTitle(label: 'Màu sắc', isDark: isDark),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: _colorOptions.length,
                        itemBuilder: (context, index) {
                          final colorHex = _colorOptions[index];
                          final color = _getColorFromHex(colorHex);
                          final isSelected = _selectedColorHex == colorHex;

                          return GestureDetector(
                            onTap: () => setState(() => _selectedColorHex = colorHex),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: isDark ? Colors.white : Colors.black87,
                                        width: 3.0,
                                      )
                                    : Border.all(
                                        color: color.withValues(alpha: 0.4),
                                        width: 1.0,
                                      ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.5),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    : [],
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                                  : null,
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

            // ── NÚT LƯU ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _save(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Lưu danh mục',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
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

class _SectionTitle extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionTitle({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
        letterSpacing: 0.3,
      ),
    );
  }
}
