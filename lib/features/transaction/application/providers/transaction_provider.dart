import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadTransactions(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rawTxs = await DatabaseHelper.instance.getTransactionsByUserId(
        userId,
      );
      _transactions = rawTxs
          .map((map) => TransactionModel.fromMap(map))
          .toList();
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách giao dịch: ${e.toString()}';
      _transactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction({
    required double amount,
    required String date,
    String? note,
    required String categoryId,
    required String type,
    required String userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final id = 'tx_${DateTime.now().millisecondsSinceEpoch}';
    final model = TransactionModel(
      id: id,
      amount: amount,
      date: date,
      note: note,
      categoryId: categoryId,
      type: type,
      userId: userId,
    );

    try {
      await DatabaseHelper.instance.insertTransaction(model.toMap());
      _transactions.insert(0, model);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi khi lưu giao dịch: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await DatabaseHelper.instance.deleteTransaction(id);
      _transactions.removeWhere((tx) => tx.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Không thể xóa giao dịch: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(TransactionModel transaction) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await DatabaseHelper.instance.updateTransaction(
        transaction.id,
        transaction.toMap(),
      );

      final index = _transactions.indexWhere((e) => e.id == transaction.id);

      if (index != -1) {
        _transactions[index] = transaction;
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();

      return false;
    }
  }

  TransactionModel? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
