class BudgetModel {
  final String id;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final double amount;
  final int month;
  final int year;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.amount,
    required this.month,
    required this.year,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'] is Map ? json['category'] as Map : {};
    return BudgetModel(
      id: json['id'] ?? '',
      categoryId: json['category_id'] as String? ?? '',
      categoryName: category['name'] as String? ?? '',
      categoryIcon: category['icon'] as String? ?? '',
      categoryColor: category['color'] as String? ?? '#FF5722',
      amount: (json['amount'] ?? 0).toDouble(),
      month: json['month'] ?? 1,
      year: json['year'] ?? DateTime.now().year,
    );
  }
}

class BudgetStatus {
  final BudgetModel budget;
  final double spent;
  final double remaining;
  final double percentage;
  final String status;

  BudgetStatus({
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.percentage,
    required this.status,
  });

  factory BudgetStatus.fromJson(Map<String, dynamic> json) => BudgetStatus(
        budget: BudgetModel(
          id: json['budget_id'] as String? ?? '',
          categoryId: json['category_id'] as String? ?? '',
          categoryName: json['category_name'] as String? ?? '',
          categoryIcon: json['category_icon'] as String? ?? '',
          categoryColor: json['category_color'] as String? ?? '#FF5722',
          amount: (json['amount'] ?? 0).toDouble(),
          month: json['month'] ?? 1,
          year: json['year'] ?? DateTime.now().year,
        ),
        spent: (json['spent'] ?? 0).toDouble(),
        remaining: (json['remaining'] ?? 0).toDouble(),
        percentage: (json['percentage'] ?? 0).toDouble(),
        status: json['status'] ?? 'ok',
      );
}
