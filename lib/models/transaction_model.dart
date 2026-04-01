class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final String walletId;
  final String walletName;
  final String currency;
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
    required this.walletId,
    required this.walletName,
    required this.currency,
    required this.date,
    this.note,
    this.slipImageUrl,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final category = json['categoryId'] is Map ? json['categoryId'] as Map : {};
    final wallet = json['walletId'] is Map ? json['walletId'] as Map : {};
    return TransactionModel(
      id: json['_id'] ?? json['id'] ?? '',
      type: json['type'] ?? 'expense',
      amount: (json['amount'] ?? 0).toDouble(),
      categoryId: category['_id'] as String? ?? json['categoryId'] as String? ?? '',
      categoryName: category['name'] as String? ?? '',
      categoryIcon: category['icon'] as String? ?? '',
      categoryColor: category['color'] as String? ?? '#FF5722',
      walletId: wallet['_id'] as String? ?? json['walletId'] as String? ?? '',
      walletName: wallet['name'] as String? ?? '',
      currency: wallet['currency'] as String? ?? 'LAK',
      date: DateTime.parse(
          json['date'] as String? ?? DateTime.now().toIso8601String()),
      note: json['note'] as String?,
      slipImageUrl: json['slipImageUrl'] as String?,
    );
  }
}
