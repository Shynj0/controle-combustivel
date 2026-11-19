import 'package:flutter/material.dart';

import '../format.dart';
import '../models.dart';
import '../widgets/series_chart.dart';

/// Dashboard: resumo + gráficos de valor, km/L e R$/km por abastecimento.
class DashboardTab extends StatelessWidget {
  final List<RefuelStats> stats;
  const DashboardTab({super.key, required this.stats});

  double? _avg(Iterable<double?> values) {
    final list = values.whereType<double>().toList();
    if (list.isEmpty) return null;
    return list.reduce((a, b) => a + b) / list.length;
  }

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_gas_station, size: 64),
              SizedBox(height: 16),
              Text(
                'Nenhum abastecimento registrado ainda.\nToque em "Abastecer" para começar.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final labels = stats.map((s) => shortDateFmt.format(s.refuel.dateTime)).toList();
    final totalSpent = stats.fold<double>(0, (a, s) => a + s.refuel.total);
    final avgKmL = _avg(stats.map((s) => s.kmPerLiter));
    final avgCostKm = _avg(stats.map((s) => s.costPerKm));
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            _Summary('Total gasto', money.format(totalSpent), Icons.payments),
            _Summary('Média km/L',
                avgKmL == null ? '—' : num2.format(avgKmL), Icons.speed),
            _Summary('Média R\$/km',
                avgCostKm == null ? '—' : money.format(avgCostKm), Icons.route),
          ],
        ),
        const SizedBox(height: 8),
        SeriesChart(
          title: 'Valor de cada abastecimento',
          unit: 'R\$',
          labels: labels,
          values: stats.map((s) => s.refuel.total).toList(),
          format: num2.format,
          color: scheme.primary,
          bars: true,
        ),
        SeriesChart(
          title: 'Consumo',
          unit: 'km/L',
          labels: labels,
          values: stats.map((s) => s.kmPerLiter).toList(),
          format: num2.format,
          color: Colors.orange.shade700,
        ),
        SeriesChart(
          title: 'Custo por quilômetro',
          unit: 'R\$/km',
          labels: labels,
          values: stats.map((s) => s.costPerKm).toList(),
          format: num2.format,
          color: Colors.indigo,
        ),
        const SizedBox(height: 72),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Summary(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 4),
              FittedBox(
                child: Text(value, style: theme.textTheme.titleMedium),
              ),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
