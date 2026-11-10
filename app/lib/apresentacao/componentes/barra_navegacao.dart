import 'package:flutter/material.dart';

import '../../core/rotas/rotas.dart';
import '../../core/tema/cores.dart';
import '../../core/tema/dimensoes.dart';
import '../../core/tema/tipografia.dart';

export '../../core/rotas/rotas.dart' show AbaPrincipal;

/// Barra inferior com as abas principais (Hoje · Relaxar · Diário).
class BarraNavegacaoSonoLeve extends StatelessWidget {
  const BarraNavegacaoSonoLeve({
    super.key,
    required this.abaAtual,
    required this.aoSelecionar,
  });

  final AbaPrincipal abaAtual;
  final ValueChanged<AbaPrincipal> aoSelecionar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CoresSonoLeve.fundo,
        border: Border(top: BorderSide(color: CoresSonoLeve.borda)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimensoes.espacoP, 8, Dimensoes.espacoP, 8),
          child: Row(
            children: [
              for (final aba in AbaPrincipal.values)
                Expanded(
                  child: _ItemNavegacao(
                    aba: aba,
                    selecionado: aba == abaAtual,
                    aoTocar: () => aoSelecionar(aba),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemNavegacao extends StatelessWidget {
  const _ItemNavegacao({
    required this.aba,
    required this.selecionado,
    required this.aoTocar,
  });

  final AbaPrincipal aba;
  final bool selecionado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final cor =
        selecionado ? CoresSonoLeve.texto : CoresSonoLeve.textoSecundario;
    return Semantics(
      button: true,
      selected: selecionado,
      label: aba.rotulo,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Material(
          color: selecionado ? CoresSonoLeve.superficie : Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensoes.raioCartao),
          child: InkWell(
            onTap: aoTocar,
            borderRadius: BorderRadius.circular(Dimensoes.raioCartao),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(aba.icone, size: 20, color: cor),
                  const SizedBox(height: 4),
                  Text(aba.rotulo,
                      style: TipografiaSonoLeve.mini.copyWith(color: cor)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
