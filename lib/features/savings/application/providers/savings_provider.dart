import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/models/savings_goal_model.dart';
import '../../domain/entities/savings_goal.dart';

class SavingsProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<SavingsGoal> _goals = [];
  bool _isLoading = false;

  List<SavingsGoal> get goals => _goals;
  bool get isLoading => _isLoading;

  Future<void> loadGoals(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _dbHelper.getSavingsGoalsByUserId(userId);
      _goals = data.map((e) => SavingsGoalModel.fromMap(e)).toList();
    } catch (e) {
      debugPrint('Error loading savings goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addGoal(SavingsGoalModel goal) async {
    try {
      await _dbHelper.insertSavingsGoal(goal.toMap());
      await loadGoals(goal.userId);
      return true;
    } catch (e) {
      debugPrint('Error adding savings goal: $e');
      return false;
    }
  }

  Future<bool> updateGoal(SavingsGoalModel goal) async {
    try {
      await _dbHelper.updateSavingsGoal(goal.id, goal.toMap());
      await loadGoals(goal.userId);
      return true;
    } catch (e) {
      debugPrint('Error updating savings goal: $e');
      return false;
    }
  }

  Future<bool> deleteGoal(String id, String userId) async {
    try {
      await _dbHelper.deleteSavingsGoal(id);
      await loadGoals(userId);
      return true;
    } catch (e) {
      debugPrint('Error deleting savings goal: $e');
      return false;
    }
  }

  Future<bool> addFunds(String goalId, double amount, String userId) async {
    try {
      final goal = _goals.firstWhere((g) => g.id == goalId);
      final updatedAmount = goal.currentAmount + amount;
      
      final updatedGoal = SavingsGoalModel(
        id: goal.id,
        name: goal.name,
        targetAmount: goal.targetAmount,
        currentAmount: updatedAmount,
        deadline: goal.deadline,
        colorHex: goal.colorHex,
        userId: goal.userId,
      );

      await _dbHelper.updateSavingsGoal(goal.id, updatedGoal.toMap());
      await loadGoals(userId);
      return true;
    } catch (e) {
      debugPrint('Error adding funds to savings goal: $e');
      return false;
    }
  }
}
