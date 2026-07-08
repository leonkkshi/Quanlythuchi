// lib/features/reports/application/providers/report_provider.dart

import 'package:flutter/material.dart';

import '../../domain/entities/category_summary.dart';
import '../../domain/entities/monthly_summary.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/entities/report_transaction.dart';
import '../../data/repositories/report_repository.dart';

/// Provider quản lý state và logic báo cáo.
class ReportProvider extends ChangeNotifier {
  final ReportRepository _repository;

  ReportProvider({ReportRepository? repository})
      : _repository = repository ?? ReportRepository();

  bool _isLoading = false;
  String? _errorMessage;
  String? _userId;
  List<MonthlySummary> _monthlySummary = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ReportPeriod get currentPeriod => _repository.currentPeriod;
  DateTime? get customStart => _repository.customStart;
  DateTime? get customEnd => _repository.customEnd;

  List<ReportTransaction> get transactions => _repository.transactions;
  List<MonthlySummary> get monthlySummary => _monthlySummary;

  double get totalIncome => _repository.getTotalIncome();
  double get totalExpense => _repository.getTotalExpense();
  double get balance => _repository.getBalance();
  List<CategorySummary> get expenseByCategory =>
      _repository.getExpenseByCategory();

  Future<void> loadReports(String userId) async {
    _userId = userId;
    await _refresh();
  }

  Future<void> setPeriod(ReportPeriod period) async {
    await filterTransactions(period);
  }

  Future<void> setCustomRange(DateTime start, DateTime end) async {
    await filterTransactions(
      ReportPeriod.custom,
      start: start,
      end: end,
    );
  }

  Future<void> filterTransactions(
    ReportPeriod period, {
    DateTime? start,
    DateTime? end,
  }) async {
    if (_userId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.filterTransactions(
        period,
        start: start,
        end: end,
      );
      _monthlySummary = await _repository.getMonthlySummary();
    } catch (e) {
      _errorMessage = 'Không thể tải báo cáo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_userId == null) return;
    await _refresh();
  }

  Future<void> _refresh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.init(_userId!);
      _monthlySummary = await _repository.getMonthlySummary();
    } catch (e) {
      _errorMessage = 'Không thể tải báo cáo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
