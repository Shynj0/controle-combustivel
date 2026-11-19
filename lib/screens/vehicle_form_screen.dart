import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../brasil_api.dart';
import '../format.dart';
import '../models.dart';

/// Cadastro do veículo (marca/modelo vindos da BrasilAPI).
class VehicleFormScreen extends StatefulWidget {
  final AppState state;
  const VehicleFormScreen({super.key, required this.state});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _api = BrasilApi();
  final _formKey = GlobalKey<FormState>();
  final _yearCtrl = TextEditingController();
  final _engineCtrl = TextEditingController();

  List<Brand> _brands = [];
  List<String> _models = [];
  Brand? _brand;
  String? _model;

  bool _loadingBrands = true;
  bool _loadingModels = false;
  String? _apiError;
  String? _brandError;
  String? _modelError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    _engineCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadBrands() async {
    setState(() {
      _loadingBrands = true;
      _apiError = null;
    });
    try {
      final brands = await _api.fetchBrands();
      if (!mounted) return;
      setState(() {
        _brands = brands;
        _loadingBrands = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingBrands = false;
        _apiError =
            'Não foi possível carregar as marcas. Verifique sua conexão com a internet.';
      });
    }
  }

  Future<void> _onBrandSelected(Brand? brand) async {
    setState(() {
      _brand = brand;
      _model = null;
      _models = [];
      _brandError = null;
      _apiError = null;
      _loadingModels = brand != null;
    });
    if (brand == null) return;
    try {
      final models = await _api.fetchModels(brand.code);
      if (!mounted || _brand?.code != brand.code) return;
      setState(() {
        _models = models;
        _loadingModels = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingModels = false;
        _apiError = 'Não foi possível carregar os modelos desta marca.';
      });
    }
  }

  Future<void> _save() async {
    final formOk = _formKey.currentState!.validate();
    setState(() {
      _brandError = _brand == null ? 'Selecione a marca' : null;
      _modelError = _model == null ? 'Selecione o modelo' : null;
    });
    if (!formOk || _brand == null || _model == null) return;

    var engine = parseNum(_engineCtrl.text)!;
    if (engine >= 50) engine = engine / 1000; // informado em cm³ (ex.: 1600)

    setState(() => _saving = true);
    await widget.state.saveVehicle(Vehicle(
      brand: _brand!.name,
      model: _model!,
      year: int.parse(_yearCtrl.text.trim()),
      engineLiters: engine,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar veículo')),
      body: _loadingBrands
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Informe os dados do seu veículo para começar a registrar os abastecimentos.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  if (_apiError != null)
                    Card(
                      color: theme.colorScheme.errorContainer,
                      child: ListTile(
                        leading: const Icon(Icons.wifi_off),
                        title: Text(_apiError!),
                        trailing: _brands.isEmpty
                            ? TextButton(
                                onPressed: _loadBrands,
                                child: const Text('Tentar de novo'))
                            : null,
                      ),
                    ),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownMenu<Brand>(
                          expandedInsets: EdgeInsets.zero,
                          label: const Text('Marca'),
                          enableFilter: true,
                          requestFocusOnTap: true,
                          menuHeight: 300,
                          errorText: _brandError,
                          enabled: _brands.isNotEmpty,
                          dropdownMenuEntries: _brands
                              .map((b) =>
                                  DropdownMenuEntry(value: b, label: b.name))
                              .toList(),
                          onSelected: _onBrandSelected,
                        ),
                        const SizedBox(height: 16),
                        DropdownMenu<String>(
                          // Recria o campo ao trocar de marca (limpa o texto).
                          key: ValueKey(_brand?.code ?? 'sem-marca'),
                          expandedInsets: EdgeInsets.zero,
                          label: Text(_loadingModels
                              ? 'Carregando modelos...'
                              : 'Modelo'),
                          enableFilter: true,
                          requestFocusOnTap: true,
                          menuHeight: 300,
                          errorText: _modelError,
                          enabled: _brand != null &&
                              !_loadingModels &&
                              _models.isNotEmpty,
                          dropdownMenuEntries: _models
                              .map((m) => DropdownMenuEntry(value: m, label: m))
                              .toList(),
                          onSelected: (m) => setState(() {
                            _model = m;
                            _modelError = null;
                          }),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _yearCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Ano',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final y = int.tryParse((v ?? '').trim());
                            final max = DateTime.now().year + 1;
                            if (y == null || y < 1950 || y > max) {
                              return 'Informe um ano entre 1950 e $max';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _engineCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Cilindrada do motor (L)',
                            hintText: 'Ex.: 1.0, 1.6, 2.0',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final e = parseNum(v ?? '');
                            if (e == null || e <= 0) {
                              return 'Informe a cilindrada';
                            }
                            final liters = e >= 50 ? e / 1000 : e;
                            if (liters < 0.5 || liters > 10) {
                              return 'Valor inválido (use litros, ex.: 1.6)';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.check),
                    label: const Text('Salvar veículo'),
                  ),
                ],
              ),
            ),
    );
  }
}
