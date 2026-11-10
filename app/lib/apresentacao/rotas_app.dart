import 'package:flutter/material.dart';

import '../core/rotas/rotas.dart';
import '../dominio/modelos/registro_sono.dart';
import 'telas/diario/tela_historico.dart';
import 'telas/diario/tela_registrar.dart';
import 'telas/preferencias/tela_preferencias.dart';
import 'telas/relaxar/tela_player.dart';
import 'telas/respiracao/tela_respiracao.dart';
import 'telas/ritual/tela_ritual.dart';

/// Gera as rotas de detalhe com uma transição suave (fade), sem
/// deslizamentos bruscos — menos estímulo visual à noite (RNF11).
abstract final class RotasApp {
  static Route<dynamic>? gerar(RouteSettings configuracao) {
    final argumento = configuracao.arguments;
    final Widget? tela = switch (configuracao.name) {
      Rotas.ritual => const TelaRitual(),
      Rotas.player => argumento is String ? TelaPlayer(idSom: argumento) : null,
      Rotas.respiracao =>
        TelaRespiracao(idTecnica: argumento is String ? argumento : null),
      Rotas.registrar =>
        TelaRegistrar(registro: argumento is RegistroSono ? argumento : null),
      Rotas.historico => const TelaHistorico(),
      Rotas.preferencias => const TelaPreferencias(),
      _ => null,
    };
    if (tela == null) return null;

    return PageRouteBuilder<dynamic>(
      settings: configuracao,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (contexto, animacao, animacaoSecundaria) => tela,
      transitionsBuilder: (contexto, animacao, animacaoSecundaria, filho) =>
          FadeTransition(
        opacity: CurvedAnimation(parent: animacao, curve: Curves.easeOut),
        child: filho,
      ),
    );
  }
}
