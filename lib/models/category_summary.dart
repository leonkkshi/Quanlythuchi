// lib/models/category_summary.dart

/// Tổng hợp chi tiêu theo danh mục.
class CategorySummary {
  final String category;
  final double amount;
  final double percentage;

  const CategorySummary({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}
