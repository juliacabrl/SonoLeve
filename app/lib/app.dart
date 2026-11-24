import 'dart:async';

import 'package:just_audio/just_audio.dart';
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
          value: dependencias.conectividade,
        ),
        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController(dependencias)..iniciar(),
        ),
        ChangeNotifierProvider<NavegacaoController>(
          create: (_) => NavegacaoController(),
        ),
        ChangeNotifierProvider<PreferenciasController>(
          create: (_) => PreferenciasController(dependencias.preferencias),
        ),
        ChangeNotifierProvider<ConteudoController>(
          create: (_) => ConteudoController(
            dependencias.conteudo,
            dependencias.conectividade,
          ),
        ),
        ChangeNotifierProvider<ChecklistController>(
          create: (_) => ChecklistController(dependencias.checklist),
        ),
        ChangeNotifierProvider<RegistroSonoController>(
          create: (_) => RegistroSonoController(dependencias.registros),
        ),
        ChangeNotifierProvider<PlayerController>(
          create: (_) => PlayerController(
            audio: dependencias.conectividadeSimulada == null
                ? AudioPlayer()
                : null,
          ),
        ),
      ],
      child: const _InterfaceSonoLeve(),
    );
  }
}

class _InterfaceSonoLeve extends StatefulWidget {
  const _InterfaceSonoLeve();

  @override
  State<_InterfaceSonoLeve> createState() => _InterfaceSonoLeveState();
}

class _InterfaceSonoLeveState extends State<_InterfaceSonoLeve> {
  Timer? _relogio;

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _relogio = Timer(
      Duration(milliseconds: 60000 - agora.millisecondsSinceEpoch % 60000),
      () {
        setState(() {});
        _relogio = Timer.periodic(
          const Duration(minutes: 1),
          (_) => setState(() {}),
        );
      },
    );
  }

  @override
  void dispose() {
    _relogio?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferencias = context.watch<PreferenciasController>().preferencias;
    final diurno =
        preferencias.temaAutomatico &&
        !preferencias.ehPeriodoNoturno(DateTime.now());

    return MaterialApp(
      title: 'SonoLeve',
      debugShowCheckedModeBanner: false,
      theme: diurno ? TemaApp.diurno : TemaApp.escuro,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const PortaoAutenticacao(),
      onGenerateRoute: RotasApp.gerar,
    );
  }
}
