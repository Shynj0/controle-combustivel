import 'package:flutter/material.dart';

import '../app_state.dart';
import '../format.dart';
import '../models.dart';

/// Lista de abastecimentos (mais recente primeiro) com os indicadores.
class HistoryTab extends StatelessWidget {
  final AppState state;
  final List<RefuelStats> stats;
  const HistoryTab({super.key, required this.state, required this.stats});

  Future<void> _confirmDelete(BuildContext context, Refuel r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir abastecimento?'),
        content: Text(
            '${r.fuel.label} de ${dateTimeFmt.format(r.dateTime)} será removido.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir')),
        ],
      ),
    );
    if (ok == true) await state.removeRefuel(r.id);
  }

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const Center(child: Text('Nenhum abastecimento registrado.'));
    }
    final items = stats.reversed.toList();
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final s = items[i];
        final r = s.refuel;
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: const Icon(Icons.local_gas_station),
            ),
            title: Text('${r.fuel.label} • ${money.format(r.total)}'),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateTimeFmt.format(r.dateTime)),
                  Text(
                      '${intFmt.format(r.odometer)} km • ${num2.format(r.liters)} L • ${money.format(r.pricePerLiter)}/L'),
                  const SizedBox(height: 4),
                  Text(
                    s.hasIndicators
                        ? '${num2.format(s.kmPerLiter)} km/L • ${money.format(s.costPerKm)}/km'
                        : 'Abastecimento de referência (sem indicadores)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            isThreeLine: true,
            trailing: IconButton(
              tooltip: 'Excluir',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, r),
            ),
          ),
        );
      },
    );
  }
}
