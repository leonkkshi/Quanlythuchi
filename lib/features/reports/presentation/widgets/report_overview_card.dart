// lib/features/reports/presentation/widgets/report_overview_card.dart

import 'package:flutter/material.dart';

import '../../../../widgets/currency_formatter.dart';

/// Card tổng quan: thu, chi, số dư.
class ReportOverviewCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final String currency;

  const ReportOverviewCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng quan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _MetricRow(
              icon: Icons.arrow_downward_rounded,
              iconColor: Colors.green,
              label: 'Tổng thu',
              value: CurrencyFormatter.format(totalIncome, currency),
            ),
            const SizedBox(height: 12),
            _MetricRow(
              icon: Icons.arrow_upward_rounded,
              iconColor: Colors.redAccent,
              label: 'Tổng chi',
              value: CurrencyFormatter.format(totalExpense, currency),
            ),
            const Divider(height: 28),
            _MetricRow(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: theme.colorScheme.primary,
              label: 'Số dư',
              value: CurrencyFormatter.format(balance, currency),
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isBold;

  const _MetricRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
