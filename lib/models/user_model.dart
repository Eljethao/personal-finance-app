class UserModel {
  final String id;
  final String name;
  final String phone;
  final String preferredLanguage;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.preferredLanguage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? json['_id'] ?? '',
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        preferredLanguage: json['preferredLanguage'] ?? 'lo',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'preferredLanguage': preferredLanguage,
      };
}
