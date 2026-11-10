import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/rotas/rotas.dart';
import '../../../core/tema/cores.dart';
import '../../../core/tema/dimensoes.dart';
import '../../../core/tema/tipografia.dart';
import '../../../core/utils/formatadores.dart';
import '../../../estado/navegacao_controller.dart';
import '../../componentes/componentes.dart';

/// Aba "Hoje" — `prototype/figma/01-hoje.svg`.
class TelaHoje extends StatelessWidget {
  const TelaHoje({super.key});

  @override
  Widget build(BuildContext context) {
    final agora = DateTime.now();
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: Dimensoes.paddingTela,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Dimensoes.espacoG),
            Row(
              children: [
                const Expanded(
                    child: Text('sonoleve', style: TipografiaSonoLeve.marca)),
                IconButton(
                  tooltip: 'Preferências',
                  onPressed: () =>
                      Navigator.of(context).pushNamed(Rotas.preferencias),
                  icon: const Icon(Icons.tune,
                      color: CoresSonoLeve.textoSecundario),
                ),
              ],
            ),
            const SizedBox(height: Dimensoes.espacoM),
            Sobrelinha(Formatadores.cabecalhoHoje(agora)),
            const SizedBox(height: Dimensoes.espacoG),
            const TituloTela('O dia pode\nficar lá fora.'),
            const SizedBox(height: Dimensoes.espacoXxg + Dimensoes.espacoG),
            const Center(
                child: AneisConcentricos(
                    child: IconeAneis(Icons.bedtime_outlined))),
            const SizedBox(height: Dimensoes.espacoXxg + Dimensoes.espacoP),
            const Center(
              child: Text('Um momento só seu, antes de dormir.',
                  style: TipografiaSonoLeve.corpo),
            ),
            const SizedBox(height: Dimensoes.espacoXg),
            BotaoPrimario(
              texto: 'Começar a relaxar',
              aoTocar: () =>
                  context.read<NavegacaoController>().ir(AbaPrincipal.relaxar),
            ),
            const SizedBox(height: Dimensoes.espacoG),
            Row(
              children: [
                Expanded(
                  child: CartaoAtalho(
                    icone: Icons.bedtime_outlined,
                    texto: 'Meu ritual',
                    aoTocar: () =>
                        Navigator.of(context).pushNamed(Rotas.ritual),
                  ),
                ),
                const SizedBox(width: Dimensoes.espacoM),
                Expanded(
                  child: CartaoAtalho(
                    icone: Icons.air,
                    texto: 'Respirar',
                    aoTocar: () =>
                        Navigator.of(context).pushNamed(Rotas.respiracao),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensoes.espacoXg),
          ],
        ),
      ),
    );
  }
}
