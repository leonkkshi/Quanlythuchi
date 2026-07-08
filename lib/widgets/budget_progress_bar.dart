import 'package:flutter/material.dart';

/// A reusable progress bar widget for displaying budget usage.
///
/// * `progress` – value between 0.0 and 1.0 representing used budget.
/// * `percentage` – optional pre‑formatted percentage string (e.g. "45 %").
/// * `color` – color of the filled portion (usually the primary accent).
/// * `isDark` – whether the surrounding theme is dark; used for background colour.
class BudgetProgressBar extends StatelessWidget {
  const BudgetProgressBar({
    Key? key,
    required this.progress,
    required this.percentage,
    required this.color,
    required this.isDark,
    this.height = 8.0,
  }) : super(key: key);

  final double progress; // 0.0 – 1.0
  final String percentage; // e.g. "45 %"
  final Color color;
  final bool isDark;
  final double height;

  @override
  Widget build(BuildContext context) {
    final background = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: height,
              backgroundColor: background,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          percentage,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}
