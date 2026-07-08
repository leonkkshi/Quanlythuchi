// lib/features/reports/presentation/widgets/monthly_bar_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../models/monthly_summary.dart';

/// Bar chart thu/chi theo tháng.
class MonthlyBarChart extends StatelessWidget {
  final List<MonthlySummary> data;

  const MonthlyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final hasData = data.any((m) => m.income > 0 || m.expense > 0);

    if (!hasData) {
      return const SizedBox(
        height: 220,
        child: Center(child: Text('Chưa có dữ liệu theo tháng')),
      );
    }

    final maxY = data
        .map((m) => m.income > m.expense ? m.income : m.expense)
        .fold(0.0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          maxY: maxY <= 0 ? 100 : maxY * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text(
                    _compact(value),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 1 || index > 12) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'T$index',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(12, (index) {
            final month = data[index];
            return BarChartGroupData(
              x: month.month,
              barRods: [
                BarChartRodData(
                  toY: month.income,
                  color: Colors.green,
                  width: 8,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: month.expense,
                  color: Colors.redAccent,
                  width: 8,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  String _compact(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toInt().toString();
  }
}
