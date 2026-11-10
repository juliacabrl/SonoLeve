import 'package:flutter/material.dart';

import '../../core/tema/cores.dart';
import '../../core/tema/dimensoes.dart';
import '../../core/tema/tipografia.dart';

/// Indicador de carregamento discreto.
class EstadoCarregando extends StatelessWidget {
  const EstadoCarregando({super.key, this.mensagem});

  final String? mensagem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: CoresSonoLeve.lavanda),
          ),
          if (mensagem != null) ...[
            const SizedBox(height: Dimensoes.espacoM),
            Text(mensagem!, style: TipografiaSonoLeve.legenda),
          ],
        ],
      ),
    );
  }
}

/// Mensagem para listas vazias.
class EstadoVazio extends StatelessWidget {
  const EstadoVazio({super.key, required this.icone, required this.mensagem});

  final IconData icone;
  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensoes.espacoXg),
      child: Column(
        children: [
          Icon(icone, size: 28, color: CoresSonoLeve.textoSecundario),
          const SizedBox(height: Dimensoes.espacoM),
          Text(mensagem,
              textAlign: TextAlign.center, style: TipografiaSonoLeve.corpo),
        ],
      ),
    );
  }
}

/// Aviso em linha — falhas de conexão e de validação, sem alarde (sem vermelho).
class AvisoEmLinha extends StatelessWidget {
  const AvisoEmLinha({
    super.key,
    required this.mensagem,
    this.icone = Icons.info_outline,
    this.cor = CoresSonoLeve.destaque,
  });

  final String mensagem;
  final IconData icone;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 16, color: cor),
          const SizedBox(width: Dimensoes.espacoP),
          Expanded(
            child: Text(mensagem,
                style: TipografiaSonoLeve.legenda.copyWith(color: cor)),
          ),
        ],
      ),
    );
  }
}

/// Rodapé de apoio com ícone — "Seus registros ficam protegidos na sua conta."
class NotaRodape extends StatelessWidget {
  const NotaRodape({super.key, required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icone, size: 15, color: CoresSonoLeve.textoSecundario),
        const SizedBox(width: Dimensoes.espacoP),
        Flexible(
          child: Text(texto,
              textAlign: TextAlign.center,
              style: TipografiaSonoLeve.mini.copyWith(fontSize: 11)),
        ),
      ],
    );
  }
}
