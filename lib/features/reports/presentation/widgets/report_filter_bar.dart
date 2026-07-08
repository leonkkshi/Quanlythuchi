// lib/features/reports/presentation/widgets/report_filter_bar.dart

import 'package:flutter/material.dart';

import '../../../../models/report_filter.dart';

/// Bộ lọc thời gian + date range picker.
class ReportFilterBar extends StatelessWidget {
  final ReportPeriod selectedPeriod;
  final DateTime? customStart;
  final DateTime? customEnd;
  final ValueChanged<ReportPeriod> onPeriodChanged;
  final VoidCallback onPickDateRange;

  const ReportFilterBar({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.onPickDateRange,
    this.customStart,
    this.customEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ReportPeriod.values.map((period) {
              final isSelected = selectedPeriod == period;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(period.label),
                  selected: isSelected,
                  onSelected: (_) => onPeriodChanged(period),
                  selectedColor:
                      (Colors.orange[800] ?? Colors.orange).withOpacity(0.2),
                  checkmarkColor: Colors.orange[800],
                  labelStyle: TextStyle(
                    color: isSelected
                        ? (Colors.orange[800] ?? Colors.orange)
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (selectedPeriod == ReportPeriod.custom &&
            customStart != null &&
            customEnd != null) ...[
          const SizedBox(height: 8),
          Text(
            'Từ ${_formatDate(customStart!)} đến ${_formatDate(customEnd!)}',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onPickDateRange,
          icon: const Icon(Icons.date_range_rounded, size: 18),
          label: const Text('Chọn khoảng thời gian'),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
