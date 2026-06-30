class Facture {
  final int id;
  final String walletCode;
  final String provider;
  final double amount;
  final bool paid;
  final String mois;

  Facture({
    required this.id,
    required this.walletCode,
    required this.provider,
    required this.amount,
    required this.paid,
    required this.mois,
  });

  factory Facture.fromJson(Map<String, dynamic> json) => Facture(
        id: json['id'] ?? 0,
        walletCode: json['walletCode']?.toString() ?? '',
        provider: json['provider']?.toString() ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        paid: json['paid'] ?? false,
        mois: json['mois']?.toString() ?? '',
      );
}
