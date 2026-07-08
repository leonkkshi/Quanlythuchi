class BudgetModel {
  final String id;
  final String categoryId;
  final double amount;
  final String period; // YYYY-MM
  final String userId;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'amount': amount,
      'period': period,
      'user_id': userId,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      categoryId: map['category_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      period: map['period'] as String,
      userId: map['user_id'] as String,
    );
  }
}
