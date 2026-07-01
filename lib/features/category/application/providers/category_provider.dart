import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  List<CategoryModel> get expenseCategories =>
      _categories.where((cat) => cat.type == 'expense').toList();

  List<CategoryModel> get incomeCategories =>
      _categories.where((cat) => cat.type == 'income').toList();

  Future<void> loadCategories(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final rawCats = await DatabaseHelper.instance.getCategoriesByUserId(userId);
      _categories = rawCats.map((map) => CategoryModel.fromMap(map)).toList();
    } catch (_) {
      _categories = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCategory({
    required String name,
    required String type,
    required int iconCode,
    required String colorHex,
    required String userId,
  }) async {
    final id = 'cat_${DateTime.now().millisecondsSinceEpoch}';
    final model = CategoryModel(
      id: id,
      name: name,
      type: type,
      iconCode: iconCode,
      colorHex: colorHex,
      userId: userId,
    );

    try {
      await DatabaseHelper.instance.insertCategory(model.toMap());
      _categories.add(model);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await DatabaseHelper.instance.deleteCategory(id);
      _categories.removeWhere((cat) => cat.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
