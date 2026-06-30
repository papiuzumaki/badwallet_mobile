class Transaction {
  final int id;
  final String type;
  final double amount;
  final double balanceAfter;
  final String reference;
  final String createdAt;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.reference,
    required this.createdAt,
  });

  bool get isCredit => type == 'DEPOSE' || type == 'TRANSFER_RECEIVE';

  String get typeLabel {
    switch (type) {
      case 'DEPOSE':
        return 'Dépôt';
      case 'RETIRE':
        return 'Retrait';
      case 'TRANSFER_SEND':
        return 'Transfert envoyé';
      case 'TRANSFER_RECEIVE':
        return 'Transfert reçu';
      case 'PAYMENT':
        return 'Paiement facture';
      default:
        return type;
    }
  }

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] ?? 0,
        type: json['type']?.toString() ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        balanceAfter: (json['balanceAfter'] ?? 0).toDouble(),
        reference: json['reference']?.toString() ?? '',
        createdAt: json['createdAt']?.toString() ?? '',
      );
}
