class Wallet {
  final String phoneNumber;
  final String code;
  final double balance;
  final String currency;

  Wallet({
    required this.phoneNumber,
    required this.code,
    required this.balance,
    required this.currency,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        phoneNumber: json['phoneNumber']?.toString() ?? '',
        code: json['code']?.toString() ?? '',
        balance: (json['balance'] ?? 0).toDouble(),
        currency: json['currency']?.toString() ?? 'XOF',
      );
}
