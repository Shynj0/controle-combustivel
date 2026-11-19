import 'package:flutter/foundation.dart';

import 'models.dart';
import 'storage.dart';

/// Estado global do app (veículo + abastecimentos).
class AppState extends ChangeNotifier {
  final LocalStorage _storage;
  AppState(this._storage);

  Vehicle? vehicle;
  List<Refuel> refuels = []; // sempre ordenada por data (crescente)

  List<RefuelStats> get stats => computeStats(refuels);

  Future<void> load() async {
    vehicle = await _storage.loadVehicle();
    refuels = vehicle == null ? [] : await _storage.loadRefuels();
    _sort();
    notifyListeners();
  }

  Future<void> saveVehicle(Vehicle v) async {
    vehicle = v;
    refuels = [];
    await _storage.clearAll();
    await _storage.saveVehicle(v);
    notifyListeners();
  }

  Future<void> deleteVehicle() async {
    vehicle = null;
    refuels = [];
    await _storage.clearAll();
    notifyListeners();
  }

  Future<void> addRefuel(Refuel r) async {
    refuels = [...refuels, r];
    _sort();
    await _storage.saveRefuels(refuels);
    notifyListeners();
  }

  Future<void> removeRefuel(String id) async {
    refuels = refuels.where((r) => r.id != id).toList();
    await _storage.saveRefuels(refuels);
    notifyListeners();
  }

  /// A quilometragem deve crescer junto com a data dos abastecimentos.
  String? validateOdometer(double km, DateTime dt) {
    Refuel? prev;
    Refuel? next;
    for (final r in refuels) {
      if (!r.dateTime.isAfter(dt)) {
        prev = r;
      } else {
        next ??= r;
      }
    }
    if (prev != null && km <= prev.odometer) {
      return 'Deve ser maior que ${prev.odometer.toStringAsFixed(0)} km (abastecimento anterior)';
    }
    if (next != null && km >= next.odometer) {
      return 'Deve ser menor que ${next.odometer.toStringAsFixed(0)} km (abastecimento seguinte)';
    }
    return null;
  }

  void _sort() => refuels.sort((a, b) => a.dateTime.compareTo(b.dateTime));
}
