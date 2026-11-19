import 'dart:convert';

import 'package:http/http.dart' as http;

class Brand {
  final String name;
  final String code;
  const Brand({required this.name, required this.code});
}

/// Consulta marcas e modelos na BrasilAPI (tabela FIPE).
/// Docs: https://brasilapi.com.br/docs#tag/FIPE
class BrasilApi {
  static const _base = 'https://brasilapi.com.br/api/fipe';
  static const _timeout = Duration(seconds: 25);

  Future<List> _getList(String path) async {
    final res = await http.get(Uri.parse('$_base/$path')).timeout(_timeout);
    if (res.statusCode != 200) {
      throw Exception('Erro ${res.statusCode} ao consultar a BrasilAPI');
    }
    return jsonDecode(utf8.decode(res.bodyBytes)) as List;
  }

  Future<List<Brand>> fetchBrands() async {
    final list = await _getList('marcas/v1/carros');
    final brands = list
        .map((e) => Brand(
              name: (e['nome'] ?? '').toString(),
              code: (e['valor'] ?? '').toString(),
            ))
        .where((b) => b.name.isNotEmpty && b.code.isNotEmpty)
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return brands;
  }

  /// Modelos da marca selecionada.
  Future<List<String>> fetchModels(String brandCode) async {
    final list = await _getList('veiculos/v1/carros/$brandCode');
    final models = list
        .map((e) => (e['modelo'] ?? e['nome'] ?? '').toString())
        .where((m) => m.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return models;
  }
}
