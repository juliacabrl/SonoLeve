import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/tema/cores.dart';
import 'injecao/dependencias.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Barra de status discreta sobre o fundo escuro.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: CoresSonoLeve.fundo,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Protótipo de baixa fidelidade: dados mockados.
  // Integração real: trocar por `Dependencias.firebase()` (próxima etapa).
  runApp(AppSonoLeve(dependencias: Dependencias.mock()));
}
