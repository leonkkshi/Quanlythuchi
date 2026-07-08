// lib/models/monthly_summary.dart

/// Tổng hợp thu/chi theo tháng.
class MonthlySummary {
  final int month;
  final int year;
  final double income;
  final double expense;

  const MonthlySummary({
    required this.month,
    required this.year,
    required this.income,
    required this.expense,
  });

  double get balance => income - expense;
}
