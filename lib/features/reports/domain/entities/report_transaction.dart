// lib/features/reports/domain/entities/report_transaction.dart

/// Giao dịch dùng cho module báo cáo (đã resolve tên danh mục).
class ReportTransaction {
  final String id;
  final String? title;
  final double amount;
  final String type;
  final String category;
  final String date;
  final String? note;

  const ReportTransaction({
    required this.id,
    this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  factory ReportTransaction.fromMap(Map<String, dynamic> map) {
    final categoryName = map['category_name'] as String? ??
        map['category'] as String? ??
        'Khác';

    return ReportTransaction(
      id: map['id'] as String,
      title: map['title'] as String?,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      category: categoryName,
      date: map['date'] as String,
      note: map['note'] as String?,
    );
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
}
