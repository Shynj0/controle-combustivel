import 'package:intl/intl.dart';

final money = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
final num2 = NumberFormat('#,##0.00', 'pt_BR');
final intFmt = NumberFormat.decimalPattern('pt_BR');
final dateTimeFmt = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
final shortDateFmt = DateFormat('dd/MM', 'pt_BR');

/// Aceita vírgula ou ponto como separador decimal.
double? parseNum(String s) => double.tryParse(s.trim().replaceAll(',', '.'));
