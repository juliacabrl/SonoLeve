import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'apresentacao/rotas_app.dart';
import 'apresentacao/telas/portao_autenticacao.dart';
import 'core/tema/tema_app.dart';
import 'dominio/servicos/conectividade.dart';
import 'estado/auth_controller.dart';
import 'estado/checklist_controller.dart';
import 'estado/conteudo_controller.dart';
import 'estado/navegacao_controller.dart';
import 'estado/player_controller.dart';
import 'estado/preferencias_controller.dart';
import 'estado/registro_sono_controller.dart';
import 'injecao/dependencias.dart';

/// Raiz do SonoLeve: registra os controllers (Provider) e o MaterialApp.
class AppSonoLeve extends StatelessWidget {
  const AppSonoLeve({super.key, required this.dependencias});

  final Dependencias dependencias;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Dependencias>.value(value: dependencias),
        ChangeNotifierProvider<Conectividade>.value(
            value: dependencias.conectividade),
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(dependencias)..iniciar(),
        ),
        ChangeNotifierProvider<NavegacaoController>(
            create: (_) => NavegacaoController()),
        ChangeNotifierProvider<PreferenciasController>(
          create: (_) => PreferenciasController(dependencias.preferencias),
        ),
        ChangeNotifierProvider<ConteudoController>(
          create: (_) => ConteudoController(
              dependencias.conteudo, dependencias.conectividade),
        ),
        ChangeNotifierProvider<ChecklistController>(
          create: (_) => ChecklistController(dependencias.checklist),
        ),
        ChangeNotifierProvider<RegistroSonoController>(
          create: (_) => RegistroSonoController(dependencias.registros),
        ),
        ChangeNotifierProvider<PlayerController>(
            create: (_) => PlayerController()),
      ],
      child: MaterialApp(
        title: 'SonoLeve',
        debugShowCheckedModeBanner: false,
        theme: TemaApp.escuro,
        darkTheme: TemaApp.escuro,
        themeMode: ThemeMode.dark,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const PortaoAutenticacao(),
        onGenerateRoute: RotasApp.gerar,
      ),
    );
  }
}
