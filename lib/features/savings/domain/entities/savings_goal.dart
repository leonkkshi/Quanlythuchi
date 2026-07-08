class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String? deadline;
  final String? colorHex;
  final String userId;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.deadline,
    this.colorHex,
    required this.userId,
  });

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    final progress = currentAmount / targetAmount;
    return progress > 1.0 ? 1.0 : progress;
  }
}
