enum FuelType {
  etanol,
  gasolina,
  diesel;

  String get label => switch (this) {
        FuelType.etanol => 'Etanol',
        FuelType.gasolina => 'Gasolina',
        FuelType.diesel => 'Diesel',
      };
}

class Vehicle {
  final String brand;
  final String model;
  final int year;
  final double engineLiters;

  const Vehicle({
    required this.brand,
    required this.model,
    required this.year,
    required this.engineLiters,
  });

  String get engineLabel => '${engineLiters.toStringAsFixed(1)} L';

  Map<String, dynamic> toJson() => {
        'brand': brand,
        'model': model,
        'year': year,
        'engineLiters': engineLiters,
      };

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        brand: json['brand'] as String,
        model: json['model'] as String,
        year: json['year'] as int,
        engineLiters: (json['engineLiters'] as num).toDouble(),
      );
}

class Refuel {
  final String id;
  final FuelType fuel;
  final double pricePerLiter;
  final double odometer;
  final double liters;
  final DateTime dateTime;

  const Refuel({
    required this.id,
    required this.fuel,
    required this.pricePerLiter,
    required this.odometer,
    required this.liters,
    required this.dateTime,
  });

  /// Valor total = preço por litro x litros abastecidos.
  double get total => pricePerLiter * liters;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fuel': fuel.name,
        'pricePerLiter': pricePerLiter,
        'odometer': odometer,
        'liters': liters,
        'dateTime': dateTime.toIso8601String(),
      };

  factory Refuel.fromJson(Map<String, dynamic> json) => Refuel(
        id: json['id'] as String,
        fuel: FuelType.values.byName(json['fuel'] as String),
        pricePerLiter: (json['pricePerLiter'] as num).toDouble(),
        odometer: (json['odometer'] as num).toDouble(),
        liters: (json['liters'] as num).toDouble(),
        dateTime: DateTime.parse(json['dateTime'] as String),
      );
}

/// Abastecimento + indicadores calculados em relação ao anterior.
/// O primeiro abastecimento é apenas referência (indicadores nulos).
class RefuelStats {
  final Refuel refuel;
  final double? distance; // km
  final double? kmPerLiter; // km/L
  final double? costPerKm; // R$/km

  const RefuelStats(this.refuel, {this.distance, this.kmPerLiter, this.costPerKm});

  bool get hasIndicators => kmPerLiter != null && costPerKm != null;
}

/// Calcula os indicadores (todos os registros completam o tanque):
/// - distância = km atual - km do abastecimento anterior
/// - km/L = distância / litros do abastecimento atual
/// - R$/km = valor total do abastecimento atual / distância
List<RefuelStats> computeStats(List<Refuel> refuels) {
  final sorted = [...refuels]..sort((a, b) {
      final c = a.dateTime.compareTo(b.dateTime);
      return c != 0 ? c : a.odometer.compareTo(b.odometer);
    });

  final result = <RefuelStats>[];
  for (var i = 0; i < sorted.length; i++) {
    final cur = sorted[i];
    if (i == 0) {
      result.add(RefuelStats(cur));
      continue;
    }
    final distance = cur.odometer - sorted[i - 1].odometer;
    if (distance > 0 && cur.liters > 0) {
      result.add(RefuelStats(
        cur,
        distance: distance,
        kmPerLiter: distance / cur.liters,
        costPerKm: cur.total / distance,
      ));
    } else {
      result.add(RefuelStats(cur));
    }
  }
  return result;
}
