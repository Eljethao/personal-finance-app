class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final DateTime date;
  final String? note;
  final String? slipImageUrl;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.date,
    this.note,
    this.slipImageUrl,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] is Map ? json['category'] as Map : {};
    return TransactionModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'expense',
      amount: (json['amount'] ?? 0).toDouble(),
      categoryId: json['category_id'] as String? ?? '',
      categoryName: category['name'] as String? ?? '',
      categoryIcon: category['icon'] as String? ?? '',
      categoryColor: category['color'] as String? ?? '#FF5722',
      date: DateTime.parse(
          json['date'] as String? ?? DateTime.now().toIso8601String()),
      note: json['note'] as String?,
      slipImageUrl: json['slip_image_url'] as String?,
    );
  }
}
