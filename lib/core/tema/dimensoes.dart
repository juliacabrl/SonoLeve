import 'package:flutter/widgets.dart';

/// Espaçamentos e raios do SonoLeve, extraídos de `prototype/figma`
/// (telas de 390 x 844, margem lateral de 24).
abstract final class Dimensoes {
  static const double margemTela = 24;

  static const double espacoXs = 4;
  static const double espacoP = 8;
  static const double espacoM = 12;
  static const double espacoG = 16;
  static const double espacoXg = 24;
  static const double espacoXxg = 32;

  static const double raioPequeno = 12;
  static const double raioCartao = 16;
  static const double raioGrande = 20;
  static const double raioBotao = 20;
  static const double raioPilula = 32;

  static const double alturaBotao = 56;
  static const double alturaItem = 62;

  static const EdgeInsets paddingTela =
      EdgeInsets.symmetric(horizontal: margemTela);
}
