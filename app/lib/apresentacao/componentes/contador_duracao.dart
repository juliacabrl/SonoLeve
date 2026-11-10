import 'package:flutter/material.dart';

import '../../core/tema/cores.dart';
import '../../core/tema/dimensoes.dart';
import '../../core/tema/tipografia.dart';
import '../../core/utils/formatadores.dart';
import 'botoes.dart';

/// "−  7 h 00 min  +" — informa as horas dormidas (RF06).
class ContadorDuracao extends StatelessWidget {
  const ContadorDuracao({
    super.key,
    required this.minutos,
    required this.aoMudar,
    this.passo = 15,
    this.minimo = 15,
    this.maximo = 24 * 60,
  });

  final int minutos;
  final ValueChanged<int> aoMudar;
  final int passo;
  final int minimo;
  final int maximo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensoes.espacoG),
      decoration: BoxDecoration(
        color: CoresSonoLeve.superficie,
        borderRadius: BorderRadius.circular(Dimensoes.raioGrande),
      ),
      child: Row(
        children: [
          BotaoCircular(
            icone: Icons.remove,
            rotulo: 'Diminuir $passo minutos',
            aoTocar: minutos - passo >= minimo
                ? () => aoMudar(minutos - passo)
                : null,
          ),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(
                Formatadores.duracaoContador(minutos),
                textAlign: TextAlign.center,
                style: TipografiaSonoLeve.numeroGrande,
              ),
            ),
          ),
          BotaoCircular(
            icone: Icons.add,
            rotulo: 'Aumentar $passo minutos',
            aoTocar: minutos + passo <= maximo
                ? () => aoMudar(minutos + passo)
                : null,
          ),
        ],
      ),
    );
  }
}
