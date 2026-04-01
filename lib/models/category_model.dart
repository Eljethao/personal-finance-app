class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String color;
  final String type;
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.isDefault = false,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['_id'] ?? json['id'] ?? '',
        name: json['name'] ?? '',
        icon: json['icon'] ?? '',
        color: json['color'] ?? '#4CAF50',
        type: json['type'] ?? 'expense',
        isDefault: json['isDefault'] ?? false,
      );
}
