import 'package:flutter/material.dart';

/// Nomes das rotas de detalhe (empilhadas sobre as abas principais).
abstract final class Rotas {
  static const String ritual = '/ritual';
  static const String player = '/player'; // argumento: id do som (String)
  static const String respiracao =
      '/respiracao'; // argumento opcional: id da técnica
  static const String registrar =
      '/registrar'; // argumento opcional: RegistroSono
  static const String historico = '/historico';
  static const String preferencias = '/preferencias';
}

/// Abas principais (bottom navigation): Hoje · Relaxar · Diário.
enum AbaPrincipal {
  hoje('Hoje', Icons.bedtime_outlined),
  relaxar('Relaxar', Icons.graphic_eq),
  diario('Diário', Icons.menu_book_outlined);

  const AbaPrincipal(this.rotulo, this.icone);

  final String rotulo;
  final IconData icone;
}
