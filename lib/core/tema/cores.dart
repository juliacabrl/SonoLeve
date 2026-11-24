import 'package:flutter/painting.dart';

/// Paleta do SonoLeve, extraída dos protótipos em `prototype/figma`.
///
/// Todas as telas usam estes tokens — nunca cores "soltas" — para que a
/// evolução para o protótipo de alta fidelidade seja feita só aqui.
abstract final class CoresSonoLeve {
  /// Fundo das telas (azul-marinho profundo).
  static const Color fundo = Color(0xFF101827);

  /// Superfície de cartões, campos e botões secundários.
  static const Color superficie = Color(0xFF1B2A41);

  /// Bordas, divisores e trilhas (barra de progresso, slider).
  static const Color borda = Color(0xFF2B3B54);

  /// Texto principal.
  static const Color texto = Color(0xFFEEF1F7);

  /// Texto de apoio, ícones neutros.
  static const Color textoSecundario = Color(0xFFAEB8C8);

  /// Cor de ação principal (botões, seleção).
  static const Color primaria = Color(0xFF7C8DB5);

  /// Lavanda: anéis, ícones de destaque, barra do dia atual.
  static const Color lavanda = Color(0xFFA9A4C9);

  /// Lavanda translúcida (anéis externos, estados de foco).
  static const Color lavandaSuave = Color(0x55A9A4C9);

  /// Verde-sálvia: hábito concluído, progresso, indicador "Offline".
  static const Color sucesso = Color(0xFF86A99A);

  /// Âmbar suave: dicas e avisos. Também usado para erros — o estudo de
  /// caso pede evitar vermelho/branco intenso durante a noite.
  static const Color destaque = Color(0xFFD7A17B);

  /// Brilho sutil sobre superfícies.
  static const Color brilho = Color(0x12FFFFFF);

  /// Texto sobre botões primários.
  static const Color textoSobrePrimaria = fundo;
}
