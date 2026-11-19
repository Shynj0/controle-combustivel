import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Persistência local (shared_preferences, dados serializados em JSON).
class LocalStorage {
  static const _vehicleKey = 'vehicle';
  static const _refuelsKey = 'refuels';

  Future<Vehicle?> loadVehicle() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_vehicleKey);
    if (raw == null) return null;
    try {
      return Vehicle.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<List<Refuel>> loadRefuels() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_refuelsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Refuel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveVehicle(Vehicle vehicle) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vehicleKey, jsonEncode(vehicle.toJson()));
  }

  Future<void> saveRefuels(List<Refuel> refuels) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _refuelsKey, jsonEncode(refuels.map((r) => r.toJson()).toList()));
  }

  /// Remove o veículo e todos os abastecimentos associados.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_vehicleKey);
    await prefs.remove(_refuelsKey);
  }
}
