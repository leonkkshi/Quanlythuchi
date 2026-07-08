import '../../domain/entities/savings_goal.dart';

class SavingsGoalModel extends SavingsGoal {
  const SavingsGoalModel({
    required super.id,
    required super.name,
    required super.targetAmount,
    super.currentAmount = 0.0,
    super.deadline,
    super.colorHex,
    required super.userId,
  });

  factory SavingsGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingsGoalModel(
      id: map['id'] as String,
      name: map['name'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      currentAmount: (map['current_amount'] as num).toDouble(),
      deadline: map['deadline'] as String?,
      colorHex: map['color_hex'] as String?,
      userId: map['user_id'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'deadline': deadline,
      'color_hex': colorHex,
      'user_id': userId,
    };
  }
}
