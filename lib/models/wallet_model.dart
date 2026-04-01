class WalletModel {
  final String id;
  final String name;
  final String icon;
  final String currency;
  final double balance;
  final double initialBalance;

  WalletModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.currency,
    this.balance = 0,
    this.initialBalance = 0,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
        id: json['_id'] ?? json['id'] ?? '',
        name: json['name'] ?? '',
        icon: json['icon'] ?? '',
        currency: json['currency'] ?? 'LAK',
        balance: (json['balance'] ?? 0).toDouble(),
        initialBalance: (json['initialBalance'] ?? 0).toDouble(),
      );
}
