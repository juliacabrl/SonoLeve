import 'package:flutter/material.dart';

import '../../core/tema/cores.dart';
import '../../core/tema/dimensoes.dart';
import '../../core/tema/tipografia.dart';

/// "‹ Voltar" no topo das telas de detalhe, com ação opcional à direita.
class CabecalhoVoltar extends StatelessWidget {
  const CabecalhoVoltar({super.key, this.aoVoltar, this.acao});

  final VoidCallback? aoVoltar;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Voltar',
            excludeSemantics: true,
            child: InkWell(
              onTap: aoVoltar ?? () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(Dimensoes.raioPequeno),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_ios_new,
                        size: 15, color: CoresSonoLeve.textoSecundario),
                    SizedBox(width: Dimensoes.espacoM),
                    Text('Voltar', style: TipografiaSonoLeve.corpo),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          if (acao != null) acao!,
        ],
      ),
    );
  }
}

/// Título grande das telas, com subtítulo opcional.
class TituloTela extends StatelessWidget {
  const TituloTela(this.texto, {super.key, this.subtitulo});

  final String texto;
  final String? subtitulo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(texto, style: TipografiaSonoLeve.tituloTela),
        ),
        if (subtitulo != null) ...[
          const SizedBox(height: Dimensoes.espacoXg),
          Text(subtitulo!, style: TipografiaSonoLeve.corpo),
        ],
      ],
    );
  }
}

/// Rótulo em caixa alta — "SEU MOMENTO", "DIÁRIO DO SONO".
class Sobrelinha extends StatelessWidget {
  const Sobrelinha(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) =>
      Text(texto.toUpperCase(), style: TipografiaSonoLeve.sobrelinha);
}

/// Selo em pílula — "Offline", "Só seu".
class ChipStatus extends StatelessWidget {
  const ChipStatus({
    super.key,
    required this.icone,
    required this.texto,
    this.cor = CoresSonoLeve.textoSecundario,
  });

  final IconData icone;
  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensoes.raioPilula),
        border: Border.all(color: CoresSonoLeve.borda),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: cor),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TipografiaSonoLeve.legenda.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}
