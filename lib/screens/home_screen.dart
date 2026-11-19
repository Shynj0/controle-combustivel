import 'package:flutter/material.dart';

import '../app_state.dart';
import 'dashboard_tab.dart';
import 'fuel_form_screen.dart';
import 'history_tab.dart';

/// Tela principal: dashboard e histórico de abastecimentos.
class HomeScreen extends StatefulWidget {
  final AppState state;
  const HomeScreen({super.key, required this.state});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  Future<void> _confirmDeleteVehicle() async {
    final v = widget.state.vehicle!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Excluir veículo?'),
        content: Text(
            '${v.brand} ${v.model} e todos os abastecimentos associados serão removidos. Essa ação não pode ser desfeita.'),
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
    if (ok == true) await widget.state.deleteVehicle();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final v = widget.state.vehicle;
        if (v == null) return const SizedBox.shrink();
        final stats = widget.state.stats;
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Controle de Combustível'),
            actions: [
              IconButton(
                tooltip: 'Excluir veículo',
                icon: const Icon(Icons.delete_forever),
                onPressed: _confirmDeleteVehicle,
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(44),
              child: Container(
                width: double.infinity,
                color: theme.colorScheme.primaryContainer,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${v.brand} ${v.model} • ${v.year} • ${v.engineLabel}',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: IndexedStack(
            index: _index,
            children: [
              DashboardTab(stats: stats),
              HistoryTab(state: widget.state, stats: stats),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => FuelFormScreen(state: widget.state),
            )),
            icon: const Icon(Icons.add),
            label: const Text('Abastecer'),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.insights), label: 'Dashboard'),
              NavigationDestination(
                  icon: Icon(Icons.list_alt), label: 'Abastecimentos'),
            ],
          ),
        );
      },
    );
  }
}
