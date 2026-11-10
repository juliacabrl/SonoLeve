import 'package:flutter/material.dart';

import '../../core/tema/cores.dart';
import '../../core/tema/dimensoes.dart';
import '../../core/tema/tipografia.dart';

/// Hábito do ritual noturno — marcável com um toque.
class ItemChecklist extends StatelessWidget {
  const ItemChecklist({
    super.key,
    required this.titulo,
    required this.concluido,
    required this.aoTocar,
  });

  final String titulo;
  final bool concluido;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: concluido,
      label: titulo,
      excludeSemantics: true,
      child: Material(
        color: CoresSonoLeve.superficie,
        borderRadius: BorderRadius.circular(Dimensoes.raioCartao),
        child: InkWell(
          onTap: aoTocar,
          borderRadius: BorderRadius.circular(Dimensoes.raioCartao),
          child: SizedBox(
            height: Dimensoes.alturaItem,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Dimensoes.espacoG),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: concluido
                          ? CoresSonoLeve.sucesso
                          : Colors.transparent,
                      border: Border.all(
                        color: concluido
                            ? CoresSonoLeve.sucesso
                            : CoresSonoLeve.textoSecundario,
                        width: 1.5,
                      ),
                    ),
                    child: concluido
                        ? const Icon(Icons.check_rounded,
                            size: 16, color: CoresSonoLeve.fundo)
                        : null,
                  ),
                  const SizedBox(width: Dimensoes.espacoM),
                  Expanded(
                    child: Text(
                      titulo,
                      style: concluido
                          ? TipografiaSonoLeve.corpo
                              .copyWith(color: CoresSonoLeve.sucesso)
                          : TipografiaSonoLeve.corpoForte,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Barra de progresso fina (ritual noturno).
class BarraProgresso extends StatelessWidget {
  const BarraProgresso({super.key, required this.valor});

  /// Entre 0 e 1.
  final double valor;

  @override
  Widget build(BuildContext context) {
    final fracao = valor.clamp(0.0, 1.0).toDouble();
    return Semantics(
      value: '${(fracao * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: SizedBox(
          width: double.infinity,
          height: 3,
          child: Stack(
            children: [
              const Positioned.fill(
                  child: ColoredBox(color: CoresSonoLeve.borda)),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: fracao,
                heightFactor: 1,
                child: const ColoredBox(color: CoresSonoLeve.sucesso),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
