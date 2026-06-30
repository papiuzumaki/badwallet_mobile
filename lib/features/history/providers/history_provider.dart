import 'package:flutter/material.dart';
import '../../../core/services/wallet_api.dart';
import '../../../models/transaction.dart';

enum HistoryState { initial, loading, loaded, error }

class HistoryProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  HistoryState _state = HistoryState.initial;
  String? _error;

  List<Transaction> get transactions => _transactions;
  HistoryState get state => _state;
  bool get isLoading => _state == HistoryState.loading;
  String? get error => _error;

  Future<void> loadHistory(String phone) => load(phone);

  Future<void> load(String phone) async {
    _state = HistoryState.loading;
    notifyListeners();
    try {
      _transactions = await WalletApi.getTransactions(phone);
      _state = HistoryState.loaded;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _state = HistoryState.error;
    }
    notifyListeners();
  }
}
