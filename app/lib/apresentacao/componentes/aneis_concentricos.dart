import 'package:flutter/material.dart';

import '../../core/tema/cores.dart';

/// Anéis elípticos concêntricos — elemento visual central do SonoLeve
/// (Home, player e respiração).
///
/// [escala] entre 0 e 1 controla a "respiração" dos anéis: 0 = recolhidos,
/// 1 = expandidos. Usado pela tela de respiração guiada.
class AneisConcentricos extends StatelessWidget {
  const AneisConcentricos({
    super.key,
    this.largura = 254,
    this.altura = 178,
    this.escala = 1,
    this.child,
  });

  final double largura;
  final double altura;
  final double escala;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      excluding: child == null,
      child: SizedBox(
        width: largura,
        height: altura,
        child: CustomPaint(
          painter: _PintorAneis(escala.clamp(0.0, 1.0).toDouble()),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _PintorAneis extends CustomPainter {
  _PintorAneis(this.escala);

  final double escala;

  static const int _quantidade = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    // O anel externo varia entre 78% e 100% do espaço disponível.
    final fatorExterno = 0.78 + 0.22 * escala;

    for (var i = 0; i < _quantidade; i++) {
      final t = i / (_quantidade - 1); // 0 = interno, 1 = externo
      final proporcao = 0.42 + (fatorExterno - 0.42) * t;
      final opacidade = 0.85 - 0.5 * t;
      final pincel = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Color.fromRGBO(
          169, 164, 201, // CoresSonoLeve.lavanda
          opacidade,
        );
      canvas.drawOval(
        Rect.fromCenter(
          center: centro,
          width: size.width * proporcao,
          height: size.height * proporcao,
        ),
        pincel,
      );
    }
  }

  @override
  bool shouldRepaint(_PintorAneis antigo) => antigo.escala != escala;
}

/// Ícone central dos anéis.
class IconeAneis extends StatelessWidget {
  const IconeAneis(this.icone, {super.key});

  final IconData icone;

  @override
  Widget build(BuildContext context) =>
      Icon(icone, size: 30, color: CoresSonoLeve.textoSecundario);
}
