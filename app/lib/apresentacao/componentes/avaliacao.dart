import 'package:flutter/material.dart';

import '../../core/tema/cores.dart';
import '../../core/tema/dimensoes.dart';
import '../../core/tema/tipografia.dart';

/// Seleção da qualidade do sono em 1 a 5 estrelas (RF07, RN01).
class SeletorEstrelas extends StatelessWidget {
  const SeletorEstrelas({
    super.key,
    required this.valor,
    required this.aoMudar,
    required this.rotulo,
  });

  /// 1 a 5.
  final int valor;
  final ValueChanged<int> aoMudar;

  /// Texto que descreve o valor atual — "Bom".
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 1; i <= 5; i++)
              Semantics(
                button: true,
                selected: i == valor,
                label: '$i de 5 estrelas',
                excludeSemantics: true,
                child: Material(
                  color: CoresSonoLeve.superficie,
                  borderRadius: BorderRadius.circular(Dimensoes.raioCartao),
                  child: InkWell(
                    onTap: () => aoMudar(i),
                    borderRadius: BorderRadius.circular(Dimensoes.raioCartao),
                    child: SizedBox(
                      width: 54,
                      height: 54,
                      child: Icon(
                        i <= valor
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 28,
                        color: i <= valor
                            ? CoresSonoLeve.lavanda
                            : CoresSonoLeve.textoSecundario,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: Dimensoes.espacoM),
        Text(rotulo, style: TipografiaSonoLeve.corpo),
      ],
    );
  }
}

/// Estrelas pequenas, apenas leitura — lista de noites.
class EstrelasCompactas extends StatelessWidget {
  const EstrelasCompactas({super.key, required this.valor});

  final int valor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$valor de 5 estrelas',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Icon(
              i <= valor ? Icons.star_rounded : Icons.star_border_rounded,
              size: 14,
              color: CoresSonoLeve.lavanda,
            ),
        ],
      ),
    );
  }
}
