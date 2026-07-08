// lib/features/reports/presentation/widgets/expense_pie_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/category_summary.dart';

/// Pie chart chi tiêu theo danh mục.
class ExpensePieChart extends StatelessWidget {
  final List<CategorySummary> data;

  const ExpensePieChart({super.key, required this.data});

  static const _palette = [
    Color(0xFFFF9800),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
    Color(0xFF4CAF50),
    Color(0xFFE91E63),
    Color(0xFF607D8B),
    Color(0xFF795548),
    Color(0xFF009688),
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('Chưa có dữ liệu chi tiêu')),
      );
    }

    return SizedBox(
      height: 240,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 48,
          sections: List.generate(data.length, (index) {
            final item = data[index];
            return PieChartSectionData(
              color: _palette[index % _palette.length],
              value: item.amount,
              title: '${item.percentage.toStringAsFixed(0)}%',
              radius: 56,
              titleStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }),
        ),
      ),
    );
  }
}
