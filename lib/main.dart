import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app_state.dart';
import 'screens/home_screen.dart';
import 'screens/vehicle_form_screen.dart';
import 'storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  final state = AppState(LocalStorage());
  await state.load();
  runApp(FuelApp(state: state));
}

class FuelApp extends StatelessWidget {
  final AppState state;
  const FuelApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle de Combustível',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0B6E4F),
      ),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Sem veículo -> tela de cadastro; com veículo -> tela principal.
      home: ListenableBuilder(
        listenable: state,
        builder: (context, _) => state.vehicle == null
            ? VehicleFormScreen(state: state)
            : HomeScreen(state: state),
      ),
    );
  }
}
