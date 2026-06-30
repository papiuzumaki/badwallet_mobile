import 'package:flutter/material.dart';
import '../../../core/services/wallet_api.dart';
import '../../../models/transaction.dart';

enum WalletState { initial, loading, loaded, error }

class WalletProvider extends ChangeNotifier {
  double _balance = 0;
  String _currency = 'XOF';
  List<Transaction> _transactions = [];
  bool _balanceVisible = true;
  WalletState _state = WalletState.initial;
  String? _error;

  double get balance => _balance;
  String get currency => _currency;
  List<Transaction> get transactions => _transactions;
  List<Transaction> get recentTransactions => _transactions.take(5).toList();
  bool get balanceVisible => _balanceVisible;
  WalletState get state => _state;
  bool get isLoading => _state == WalletState.loading;
  String? get error => _error;
  String? get walletCode => null;

  void toggleBalanceVisibility() {
    _balanceVisible = !_balanceVisible;
    notifyListeners();
  }

  Future<void> load(String phone, String currency) async {
    _currency = currency;
    _state = WalletState.loading;
    notifyListeners();
    try {
      final balanceData = await WalletApi.getBalance(phone);
      _balance = (balanceData['balance'] ?? 0).toDouble();
      if (balanceData['currency'] != null) {
        _currency = balanceData['currency'].toString();
      }
      _transactions = await WalletApi.getTransactions(phone);
      _state = WalletState.loaded;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _state = WalletState.error;
    }
    notifyListeners();
  }

  void updateBalance(double newBalance) {
    _balance = newBalance;
    notifyListeners();
  }

  Future<void> refresh(String phone) => load(phone, _currency);

  void reset() {
    _balance = 0;
    _transactions = [];
    _state = WalletState.initial;
    _error = null;
    notifyListeners();
  }
}
