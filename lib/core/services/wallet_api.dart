import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../../models/wallet.dart';
import '../../models/transaction.dart';
import '../../models/facture.dart';

class WalletApi {
  static final _client = http.Client();

  static Future<Wallet> getWallet(String phone) async {
    final res = await _client
        .get(Uri.parse('$kBaseUrl/wallets/$phone'))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      return Wallet.fromJson(jsonDecode(res.body));
    }
    throw Exception('Portefeuille introuvable pour ce numéro');
  }

  static Future<Map<String, dynamic>> getBalance(String phone) async {
    final res = await _client
        .get(Uri.parse('$kBaseUrl/wallets/$phone/balance'))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is num) return {'balance': data.toDouble(), 'currency': 'XOF'};
      return Map<String, dynamic>.from(data);
    }
    throw Exception('Erreur lors du chargement du solde');
  }

  static Future<List<Transaction>> getTransactions(String phone) async {
    final res = await _client
        .get(Uri.parse('$kBaseUrl/wallets/$phone/transactions'))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Transaction.fromJson(e)).toList();
    }
    throw Exception('Erreur lors du chargement des transactions');
  }

  static Future<List<Transaction>> transfer({
    required String senderPhone,
    required String receiverPhone,
    required double amount,
  }) async {
    final res = await _client
        .post(
          Uri.parse('$kBaseUrl/wallets/transfer'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'senderPhone': senderPhone,
            'receiverPhone': receiverPhone,
            'amount': amount,
          }),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 200 || res.statusCode == 201) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Transaction.fromJson(e)).toList();
    }
    throw Exception('Erreur lors du transfert — vérifiez le numéro et votre solde');
  }

  static Future<List<Facture>> getFactures(String walletCode) async {
    final now = DateTime.now();
    final debut =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final fin =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}';

    final res = await _client
        .get(Uri.parse(
            '$kBaseUrl/external/factures/$walletCode?debut=$debut&fin=$fin'))
        .timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Facture.fromJson(e)).toList();
    }
    throw Exception('Erreur lors du chargement des factures');
  }

  static Future<void> payFactures({
    required String walletPhone,
    required List<int> factureIds,
  }) async {
    final res = await _client
        .post(
          Uri.parse('$kBaseUrl/wallets/pay-factures'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'walletPhone': walletPhone,
            'factureIds': factureIds,
          }),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Erreur lors du paiement des factures');
    }
  }
}
