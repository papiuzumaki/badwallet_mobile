import 'package:flutter/material.dart';
import '../../../models/facture.dart';

enum BillsState { initial, loading, loaded, paying, success, error }

class BillsProvider extends ChangeNotifier {
  List<Facture> _factures = [];
  final Set<int> _selectedIds = {};
  BillsState _state = BillsState.initial;
  String? _error;

  List<Facture> get factures => _factures;
  List<Facture> get unpaid => _factures.where((f) => !f.paid).toList();
  Set<int> get selectedIds => Set.unmodifiable(_selectedIds);
  BillsState get state => _state;
  String? get error => _error;

  double get totalSelected => _factures
      .where((f) => _selectedIds.contains(f.id))
      .fold(0.0, (sum, f) => sum + f.amount);

  bool get isLoading => _state == BillsState.loading;
  bool get isPaying  => _state == BillsState.paying;
  bool isSelected(int id) => _selectedIds.contains(id);

  static List<Facture> _mockFactures(String walletCode) => [
    Facture(id: 1, walletCode: walletCode, provider: 'SENELEC', amount: 18500, paid: false, mois: 'Juin 2026'),
    Facture(id: 2, walletCode: walletCode, provider: 'WOYAFAL', amount: 7200,  paid: false, mois: 'Juin 2026'),
    Facture(id: 3, walletCode: walletCode, provider: 'ISM',     amount: 45000, paid: false, mois: 'Juin 2026'),
    Facture(id: 4, walletCode: walletCode, provider: 'RAPIDO',  amount: 5000,  paid: false, mois: 'Juin 2026'),
  ];

  void toggleAll() {
    if (_selectedIds.length == _factures.length) {
      _selectedIds.clear();
    } else {
      _selectedIds.addAll(_factures.map((f) => f.id));
    }
    notifyListeners();
  }

  Future<void> loadFactures(String walletCode) => load(walletCode);

  Future<void> load(String walletCode) async {
    _state = BillsState.loading;
    _selectedIds.clear();
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _factures = _mockFactures(walletCode);
    _state = BillsState.loaded;
    notifyListeners();
  }

  void toggleSelection(int id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  Future<bool> paySelected(String walletPhone) async {
    if (_selectedIds.isEmpty) return false;
    _state = BillsState.paying;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _factures.removeWhere((f) => _selectedIds.contains(f.id));
    _selectedIds.clear();
    _state = BillsState.loaded;
    notifyListeners();
    return true;
  }
}
