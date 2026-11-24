import 'package:flutter/painting.dart';

import 'cores.dart';

/// Escala tipográfica do SonoLeve (fonte Manrope, embarcada no app).
///
/// Tamanhos e pesos extraídos dos protótipos em `prototype/figma`.
abstract final class TipografiaSonoLeve {
  static const String familia = 'Manrope';

  /// Títulos das telas — "O dia pode ficar lá fora."
  static const TextStyle tituloTela = TextStyle(
    fontFamily: familia,
    fontSize: 33,
    fontWeight: FontWeight.w400,
    height: 1.27,
    color: CoresSonoLeve.texto,
  );

  /// Marca no topo da Home — "sonoleve".
  static const TextStyle marca = TextStyle(
    fontFamily: familia,
    fontSize: 25,
    fontWeight: FontWeight.w400,
    color: CoresSonoLeve.texto,
  );

  /// Números de destaque — "7h 10m", "7 h 00 min".
  static const TextStyle numeroGrande = TextStyle(
    fontFamily: familia,
    fontSize: 29,
    fontWeight: FontWeight.w400,
    color: CoresSonoLeve.texto,
  );

  /// Título de cartões e itens — "Chuva suave".
  static const TextStyle tituloCartao = TextStyle(
    fontFamily: familia,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: CoresSonoLeve.texto,
  );

  /// Subtítulos de seção — "Suas noites", "Quanto tempo você dormiu?".
  static const TextStyle subtitulo = TextStyle(
    fontFamily: familia,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: CoresSonoLeve.texto,
  );

  /// Texto corrido.
  static const TextStyle corpo = TextStyle(
    fontFamily: familia,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: CoresSonoLeve.textoSecundario,
  );

  /// Texto corrido em destaque (itens de lista).
  static const TextStyle corpoForte = TextStyle(
    fontFamily: familia,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: CoresSonoLeve.texto,
  );

  /// Rótulo de botões.
  static const TextStyle botao = TextStyle(
    fontFamily: familia,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  /// Texto de apoio pequeno — descrições de itens.
  static const TextStyle legenda = TextStyle(
    fontFamily: familia,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: CoresSonoLeve.textoSecundario,
  );

  /// Rótulos em caixa alta — "SEU MOMENTO", "DIÁRIO DO SONO".
  static const TextStyle sobrelinha = TextStyle(
    fontFamily: familia,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 2,
    color: CoresSonoLeve.textoSecundario,
  );

  /// Textos mínimos — rótulos da barra de navegação e do gráfico.
  static const TextStyle mini = TextStyle(
    fontFamily: familia,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: CoresSonoLeve.textoSecundario,
  );
}
