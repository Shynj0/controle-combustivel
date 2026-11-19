import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Gráfico (linha ou barras) com a evolução de um indicador por abastecimento.
/// [values] tem um item por abastecimento; itens nulos não são desenhados
/// (ex.: o primeiro abastecimento não possui km/L nem R$/km).
class SeriesChart extends StatelessWidget {
  final String title;
  final String unit;
  final List<String> labels;
  final List<double?> values;
  final String Function(double) format;
  final Color color;
  final bool bars;

  const SeriesChart({
    super.key,
    required this.title,
    required this.unit,
    required this.labels,
    required this.values,
    required this.format,
    required this.color,
    this.bars = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = values.any((v) => v != null);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text('$title ($unit)', style: theme.textTheme.titleMedium),
            ),
            const SizedBox(height: 16),
            if (!hasData)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24, horizontal: 4),
                child: Text(
                    'Registre pelo menos 2 abastecimentos para ver este gráfico.'),
              )
            else
              LayoutBuilder(builder: (context, constraints) {
                final width = math.max(constraints.maxWidth, labels.length * 64.0);
                return SizedBox(
                  height: 220,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: width,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12, top: 8),
                        child: bars ? _bar() : _line(),
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  static const _tipStyle =
      TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12);

  FlTitlesData get _titles => FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 52,
            getTitlesWidget: (v, meta) => Text(
              format(v),
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.right,
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 1,
            getTitlesWidget: (v, meta) {
              final i = v.toInt();
              if (v != i.toDouble() || i < 0 || i >= labels.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(labels[i], style: const TextStyle(fontSize: 10)),
              );
            },
          ),
        ),
      );

  Widget _line() {
    final spots = <FlSpot>[
      for (var i = 0; i < values.length; i++)
        if (values[i] != null) FlSpot(i.toDouble(), values[i]!),
    ];
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: math.max(1, labels.length - 1).toDouble(),
        titlesData: _titles,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: color,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touched) => touched
                .map((s) => LineTooltipItem(
                    '${labels[s.x.toInt()]}\n${format(s.y)} $unit', _tipStyle))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _bar() {
    return BarChart(
      BarChartData(
        titlesData: _titles,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        alignment: BarChartAlignment.spaceAround,
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: values[i] ?? 0,
                color: color,
                width: 22,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ]),
        ],
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
                '${labels[group.x]}\n${format(rod.toY)}', _tipStyle),
          ),
        ),
      ),
    );
  }
}
