import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../format.dart';
import '../models.dart';

/// Registro de um novo abastecimento.
class FuelFormScreen extends StatefulWidget {
  final AppState state;
  const FuelFormScreen({super.key, required this.state});

  @override
  State<FuelFormScreen> createState() => _FuelFormScreenState();
}

class _FuelFormScreenState extends State<FuelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceCtrl = TextEditingController();
  final _kmCtrl = TextEditingController();
  final _litersCtrl = TextEditingController();

  FuelType _fuel = FuelType.gasolina;
  DateTime _dateTime = DateTime.now();

  @override
  void dispose() {
    _priceCtrl.dispose();
    _kmCtrl.dispose();
    _litersCtrl.dispose();
    super.dispose();
  }

  double get _total {
    final p = parseNum(_priceCtrl.text);
    final l = parseNum(_litersCtrl.text);
    if (p == null || l == null) return 0;
    return p * l;
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null) return;
    setState(() => _dateTime = DateTime(
        date.year, date.month, date.day, _dateTime.hour, _dateTime.minute));
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (time == null) return;
    setState(() => _dateTime = DateTime(_dateTime.year, _dateTime.month,
        _dateTime.day, time.hour, time.minute));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.state.addRefuel(Refuel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      fuel: _fuel,
      pricePerLiter: parseNum(_priceCtrl.text)!,
      odometer: double.parse(_kmCtrl.text.trim()),
      liters: parseNum(_litersCtrl.text)!,
      dateTime: _dateTime,
    ));
    if (mounted) Navigator.of(context).pop();
  }

  String? _positive(String? v, String msg) {
    final n = parseNum(v ?? '');
    return (n == null || n <= 0) ? msg : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Novo abastecimento')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Tipo de combustível', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<FuelType>(
                segments: FuelType.values
                    .map((f) => ButtonSegment(value: f, label: Text(f.label)))
                    .toList(),
                selected: {_fuel},
                onSelectionChanged: (s) => setState(() => _fuel = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Preço por litro',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) => _positive(v, 'Informe o preço por litro'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kmCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Quilometragem atual',
                  suffixText: 'km',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final km = double.tryParse((v ?? '').trim());
                  if (km == null) return 'Informe a quilometragem';
                  return widget.state.validateOdometer(km, _dateTime);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _litersCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Litros abastecidos',
                  suffixText: 'L',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) => _positive(v, 'Informe a quantidade de litros'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                          '${_dateTime.day.toString().padLeft(2, '0')}/${_dateTime.month.toString().padLeft(2, '0')}/${_dateTime.year}'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(
                          '${_dateTime.hour.toString().padLeft(2, '0')}:${_dateTime.minute.toString().padLeft(2, '0')}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Valor total', style: theme.textTheme.titleMedium),
                      Text(money.format(_total),
                          style: theme.textTheme.headlineSmall),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Salvar abastecimento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
