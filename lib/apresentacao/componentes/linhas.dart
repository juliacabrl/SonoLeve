import 'package:flutter/material.dart';

import '../../core/tema/cores.dart';
import '../../core/tema/dimensoes.dart';
import '../../core/tema/tipografia.dart';
import 'avaliacao.dart';

/// Noite registrada — "22 set · 7h 30 de descanso · ★★★★☆".
class LinhaRegistro extends StatelessWidget {
  const LinhaRegistro({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.estrelas,
    this.aoTocar,
  });

  final String titulo;
  final String subtitulo;
  final int estrelas;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: aoTocar != null,
      label: '$titulo, $subtitulo, $estrelas de 5 estrelas',
      excludeSemantics: true,
      child: InkWell(
        onTap: aoTocar,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: CoresSonoLeve.borda)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: TipografiaSonoLeve.corpoForte
                            .copyWith(fontSize: 15)),
                    const SizedBox(height: 6),
                    Text(subtitulo,
                        style: TipografiaSonoLeve.mini.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              EstrelasCompactas(valor: estrelas),
            ],
          ),
        ),
      ),
    );
  }
}

/// Linha de configuração — título, valor atual e um controle à direita.
class LinhaPreferencia extends StatelessWidget {
  const LinhaPreferencia({
    super.key,
    required this.titulo,
    required this.valor,
    this.trailing,
    this.aoTocar,
    this.corTitulo = CoresSonoLeve.texto,
  });

  final String titulo;
  final String valor;
  final Widget? trailing;
  final VoidCallback? aoTocar;
  final Color corTitulo;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: aoTocar != null,
      label: '$titulo: $valor',
      child: InkWell(
        onTap: aoTocar,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: CoresSonoLeve.borda)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        style: TipografiaSonoLeve.corpoForte
                            .copyWith(fontSize: 15, color: corTitulo)),
                    const SizedBox(height: 6),
                    Text(valor,
                        style:
                            TipografiaSonoLeve.legenda.copyWith(fontSize: 11)),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: Dimensoes.espacoM),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Interruptor discreto no estilo do protótipo (sem brilho).
class AlternadorSuave extends StatelessWidget {
  const AlternadorSuave({
    super.key,
    required this.ativo,
    required this.aoMudar,
    required this.rotulo,
  });

  final bool ativo;
  final ValueChanged<bool> aoMudar;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: ativo,
      label: rotulo,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => aoMudar(!ativo),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 50,
          height: 28,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: ativo ? CoresSonoLeve.primaria : CoresSonoLeve.borda,
            borderRadius: BorderRadius.circular(14),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: ativo ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                  color: CoresSonoLeve.fundo, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}
