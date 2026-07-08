// lib/services/report_repository.dart

import '../database/database_helper.dart';
import '../models/category_summary.dart';
import '../models/monthly_summary.dart';
import '../models/report_filter.dart';
import '../models/report_transaction.dart';

/// Repository đọc dữ liệu báo cáo từ SQLite.
class ReportRepository {
  final DatabaseHelper _db;

  ReportRepository({DatabaseHelper? dbHelper})
      : _db = dbHelper ?? DatabaseHelper.instance;

  String? _userId;
  ReportPeriod _period = ReportPeriod.thisMonth;
  DateTime? _customStart;
  DateTime? _customEnd;
  List<ReportTransaction> _cachedTransactions = [];

  ReportPeriod get currentPeriod => _period;
  DateTime? get customStart => _customStart;
  DateTime? get customEnd => _customEnd;
  List<ReportTransaction> get transactions => _cachedTransactions;

  Future<void> init(String userId) async {
    _userId = userId;
    await filterTransactions(_period);
  }

  /// Lọc giao dịch theo khoảng thời gian.
  Future<List<ReportTransaction>> filterTransactions(
    ReportPeriod period, {
    DateTime? start,
    DateTime? end,
  }) async {
    if (_userId == null) return [];

    _period = period;
    if (period == ReportPeriod.custom) {
      _customStart = start;
      _customEnd = end;
    }

    final range = _resolveDateRange(period, start: start, end: end);
    final raw = await _db.getTransactionsInRange(
      _userId!,
      range.start,
      range.end,
    );

    _cachedTransactions =
        raw.map((m) => ReportTransaction.fromMap(m)).toList();
    return _cachedTransactions;
  }

  double getTotalIncome() {
    return _cachedTransactions
        .where((tx) => tx.isIncome)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double getTotalExpense() {
    return _cachedTransactions
        .where((tx) => tx.isExpense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double getBalance() => getTotalIncome() - getTotalExpense();

  /// Thống kê chi tiêu theo danh mục.
  List<CategorySummary> getExpenseByCategory() {
    final expenses =
        _cachedTransactions.where((tx) => tx.isExpense).toList();
    if (expenses.isEmpty) return [];

    final Map<String, double> grouped = {};
    for (final tx in expenses) {
      grouped[tx.category] = (grouped[tx.category] ?? 0) + tx.amount;
    }

    final total = grouped.values.fold(0.0, (a, b) => a + b);
    if (total <= 0) return [];

    final entries = grouped.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries
        .map(
          (e) => CategorySummary(
            category: e.key,
            amount: e.value,
            percentage: (e.value / total) * 100,
          ),
        )
        .toList();
  }

  /// Thu/chi theo từng tháng trong năm hiện tại hoặc năm của filter.
  Future<List<MonthlySummary>> getMonthlySummary({int? year}) async {
    if (_userId == null) return [];

    final targetYear = year ?? _resolveDateRange(_period).end.year;
    final raw = await _db.getMonthlyAggregates(_userId!, targetYear);

    final Map<int, MonthlySummary> map = {};
    for (var month = 1; month <= 12; month++) {
      map[month] = MonthlySummary(
        month: month,
        year: targetYear,
        income: 0,
        expense: 0,
      );
    }

    for (final row in raw) {
      final month = row['month'] as int;
      final type = row['type'] as String;
      final total = (row['total'] as num).toDouble();
      final current = map[month]!;

      map[month] = MonthlySummary(
        month: month,
        year: targetYear,
        income: type == 'income' ? total : current.income,
        expense: type == 'expense' ? total : current.expense,
      );
    }

    return map.values.toList();
  }

  ({DateTime start, DateTime end}) _resolveDateRange(
    ReportPeriod period, {
    DateTime? start,
    DateTime? end,
  }) {
    final now = DateTime.now();
    switch (period) {
      case ReportPeriod.today:
        return (
          start: DateTime(now.year, now.month, now.day),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      case ReportPeriod.thisWeek:
        final weekday = now.weekday;
        final weekStart = now.subtract(Duration(days: weekday - 1));
        return (
          start: DateTime(weekStart.year, weekStart.month, weekStart.day),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      case ReportPeriod.thisMonth:
        return (
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case ReportPeriod.thisYear:
        return (
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31, 23, 59, 59),
        );
      case ReportPeriod.custom:
        final customStart = start ?? _customStart ?? now;
        final customEnd = end ?? _customEnd ?? now;
        return (
          start: DateTime(
            customStart.year,
            customStart.month,
            customStart.day,
          ),
          end: DateTime(
            customEnd.year,
            customEnd.month,
            customEnd.day,
            23,
            59,
            59,
          ),
        );
    }
  }
}
