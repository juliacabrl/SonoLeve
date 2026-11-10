import 'package:flutter/material.dart';

import '../../core/tema/cores.dart';
import '../../core/tema/dimensoes.dart';
import '../../core/tema/tipografia.dart';

/// Uma barra do gráfico semanal.
class BarraGrafico {
  const BarraGrafico(
      {required this.rotulo, this.minutos, this.destaque = false});

  final String rotulo;

  /// `null` = noite sem registro.
  final int? minutos;

  /// Barra do dia atual (cor lavanda).
  final bool destaque;
}

/// Gráfico de barras dos últimos 7 dias (RF11).
class GraficoSemanal extends StatelessWidget {
  const GraficoSemanal({
    super.key,
    required this.barras,
    required this.titulo,
    required this.valorPrincipal,
    required this.detalhe,
    this.referenciaMinutos = 9 * 60,
  });

  final List<BarraGrafico> barras;
  final String titulo;
  final String valorPrincipal;
  final String detalhe;

  /// Valor que corresponde à altura máxima da barra.
  final int referenciaMinutos;

  static const double _alturaArea = 96;

  @override
  Widget build(BuildContext context) {
    final maiorRegistro =
        barras.fold<int>(0, (m, b) => (b.minutos ?? 0) > m ? b.minutos! : m);
    final topo =
        maiorRegistro > referenciaMinutos ? maiorRegistro : referenciaMinutos;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: CoresSonoLeve.superficie,
        borderRadius: BorderRadius.circular(Dimensoes.raioGrande),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TipografiaSonoLeve.legenda),
          const SizedBox(height: Dimensoes.espacoP),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                  child: Text(valorPrincipal,
                      style: TipografiaSonoLeve.numeroGrande)),
              Text(detalhe, style: TipografiaSonoLeve.legenda),
            ],
          ),
          const SizedBox(height: Dimensoes.espacoG),
          Semantics(
            label: 'Gráfico das horas dormidas nos últimos 7 dias',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final barra in barras)
                  _Barra(barra: barra, topo: topo, alturaArea: _alturaArea),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra(
      {required this.barra, required this.topo, required this.alturaArea});

  final BarraGrafico barra;
  final int topo;
  final double alturaArea;

  @override
  Widget build(BuildContext context) {
    final minutos = barra.minutos;
    final altura = minutos == null
        ? 6.0
        : (minutos / topo * alturaArea).clamp(10.0, alturaArea).toDouble();
    final cor = minutos == null
        ? CoresSonoLeve.borda
        : (barra.destaque ? CoresSonoLeve.lavanda : CoresSonoLeve.primaria);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: alturaArea,
          width: 22,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 20,
              height: altura,
              decoration: BoxDecoration(
                  color: cor, borderRadius: BorderRadius.circular(7)),
            ),
          ),
        ),
        const SizedBox(height: Dimensoes.espacoP),
        Text(barra.rotulo, style: TipografiaSonoLeve.mini),
      ],
    );
  }
}
