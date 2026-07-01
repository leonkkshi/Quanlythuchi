class Transaction {
  final String id;
  final double amount;
  final String date; // ISO 8601 String
  final String? note;
  final String categoryId;
  final String type; // 'expense' or 'income'
  final String userId;

  const Transaction({
    required this.id,
    required this.amount,
    required this.date,
    this.note,
    required this.categoryId,
    required this.type,
    required this.userId,
  });
}
