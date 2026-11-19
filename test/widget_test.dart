import 'package:controle_combustivel/models.dart';
import 'package:flutter_test/flutter_test.dart';

Refuel _r(String id, double km, double liters, double price, DateTime d) => Refuel(
      id: id,
      fuel: FuelType.gasolina,
      pricePerLiter: price,
      odometer: km,
      liters: liters,
      dateTime: d,
    );

void main() {
  test('valor total = preço por litro x litros', () {
    final r = _r('1', 1000, 40, 6.0, DateTime(2026, 1, 1));
    expect(r.total, 240.0);
  });

  test('primeiro abastecimento não possui indicadores', () {
    final s = computeStats([_r('1', 1000, 40, 6.0, DateTime(2026, 1, 1))]);
    expect(s.single.hasIndicators, false);
  });

  test('km/L e R\$/km a partir do segundo abastecimento', () {
    final s = computeStats([
      _r('2', 1400, 40, 6.0, DateTime(2026, 1, 10)),
      _r('1', 1000, 35, 6.0, DateTime(2026, 1, 1)),
    ]);
    expect(s[0].hasIndicators, false);
    expect(s[1].distance, 400);
    expect(s[1].kmPerLiter, closeTo(10.0, 1e-9)); // 400 / 40
    expect(s[1].costPerKm, closeTo(0.6, 1e-9)); // 240 / 400
  });
}
