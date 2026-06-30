import 'package:flutter/material.dart';
import '../../../core/services/wallet_api.dart';
import '../../../models/transaction.dart';

enum TransferState { initial, loading, success, error }

class TransferProvider extends ChangeNotifier {
  TransferState _state = TransferState.initial;
  String? _error;
  Transaction? _resultTransaction;

  TransferState get state => _state;
  bool get isLoading => _state == TransferState.loading;
  String? get error => _error;
  Transaction? get resultTransaction => _resultTransaction;
  Transaction? get lastTransfer => _resultTransaction;

  void reset() {
    _state = TransferState.initial;
    _error = null;
    _resultTransaction = null;
    notifyListeners();
  }

  Future<Transaction?> transfer({
    required String senderPhone,
    required String receiverPhone,
    required double amount,
  }) async {
    _state = TransferState.loading;
    _error = null;
    notifyListeners();
    try {
      final txs = await WalletApi.transfer(
        senderPhone: senderPhone,
        receiverPhone: receiverPhone,
        amount: amount,
      );
      _resultTransaction = txs.firstWhere(
        (t) => t.type == 'TRANSFER_SEND',
        orElse: () => txs.first,
      );
      _state = TransferState.success;
      notifyListeners();
      return _resultTransaction;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _state = TransferState.error;
      notifyListeners();
      return null;
    }
  }
}
