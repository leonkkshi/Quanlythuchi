class Category {
  final String id;
  final String name;
  final String type; // 'expense' or 'income'
  final int iconCode;
  final String colorHex;
  final String userId;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCode,
    required this.colorHex,
    required this.userId,
  });
}
