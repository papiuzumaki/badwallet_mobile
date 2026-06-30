import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/wallet_api.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  String? _phone;
  String? _walletCode;
  String? _currency;
  bool _isLoading = false;
  String? _error;

  AuthStatus get status => _status;
  String? get phone => _phone;
  String? get walletCode => _walletCode;
  String? get currency => _currency;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _phone = prefs.getString('phone');
      _walletCode = prefs.getString('walletCode');
      _currency = prefs.getString('currency') ?? 'XOF';
    } catch (_) {}
    _status = _phone != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> login(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final wallet = await WalletApi.getWallet(phone);
      _phone = wallet.phoneNumber.isNotEmpty ? wallet.phoneNumber : phone;
      _walletCode = wallet.code;
      _currency = wallet.currency.isNotEmpty ? wallet.currency : 'XOF';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('phone', _phone!);
      if (_walletCode != null) await prefs.setString('walletCode', _walletCode!);
      await prefs.setString('currency', _currency!);
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _error = 'Numéro introuvable. Vérifiez et réessayez.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
    _phone = null;
    _walletCode = null;
    _currency = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
