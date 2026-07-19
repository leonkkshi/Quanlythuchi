// lib/features/reports/presentation/widgets/category_summary_list.dart

import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../domain/entities/category_summary.dart';
import '../../../../widgets/currency_formatter.dart';

/// Danh sách tổng hợp theo danh mục.
class CategorySummaryList extends StatelessWidget {
  final List<CategorySummary> data;
  final String currency;

  const CategorySummaryList({
    super.key,
    required this.data,
    required this.currency,
  });

  static const _colors = [
    Color(0xFFFF9800),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
    Color(0xFF4CAF50),
    Color(0xFFE91E63),
    Color(0xFF607D8B),
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Text('Không có danh mục chi tiêu')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox.shrink(),
      itemBuilder: (context, index) {
        final item = data[index];
        final color = _colors[index % _colors.length];

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(IconlyBold.category, color: color, size: 18),
          ),
          title: Text(
            item.category,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('${item.percentage.toStringAsFixed(1)}%'),
          trailing: Text(
            CurrencyFormatter.format(item.amount, currency),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
