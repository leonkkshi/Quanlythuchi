import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/models/budget_model.dart';

class BudgetProvider extends ChangeNotifier {
  List<BudgetModel> _budgets = [];
  bool _isLoading = false;

  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;

  Future<void> loadBudgets(String userId, String period) async {
    _isLoading = true;
    notifyListeners();

    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'budgets',
        where: 'user_id = ? AND period = ?',
        whereArgs: [userId, period],
      );

      _budgets = maps.map((map) => BudgetModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error loading budgets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setBudget({
    required String userId,
    required String categoryId,
    required String period,
    required double amount,
  }) async {
    try {
      final db = await DatabaseHelper.instance.database;

      if (amount <= 0) {
        // Delete if set to 0 or negative
        await db.delete(
          'budgets',
          where: 'user_id = ? AND category_id = ? AND period = ?',
          whereArgs: [userId, categoryId, period],
        );
      } else {
        // Upsert
        final budget = BudgetModel(
          id: '${userId}_${categoryId}_$period',
          categoryId: categoryId,
          amount: amount,
          period: period,
          userId: userId,
        );

        await db.insert(
          'budgets',
          budget.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // Reload to update UI state
      await loadBudgets(userId, period);
    } catch (e) {
      debugPrint('Error setting budget: $e');
    }
  }
}
