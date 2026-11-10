import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/tema/cores.dart';
import '../../../core/tema/dimensoes.dart';
import '../../../core/tema/tipografia.dart';
import '../../../estado/conteudo_controller.dart';
import '../../../estado/player_controller.dart';
import '../../componentes/componentes.dart';

/// Player de som em loop — `prototype/figma/04-player.svg`.
class TelaPlayer extends StatefulWidget {
  const TelaPlayer({super.key, required this.idSom});

  final String idSom;

  @override
  State<TelaPlayer> createState() => _TelaPlayerState();
}

class _TelaPlayerState extends State<TelaPlayer> {
  /// Até o player receber o som (próximo quadro), exibe o som pedido.
  bool _preparado = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final som = context.read<ConteudoController>().somPorId(widget.idSom);
      if (som != null) context.read<PlayerController>().preparar(som);
      setState(() => _preparado = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final conteudo = context.watch<ConteudoController>();
    final som = _preparado
        ? (player.som ?? conteudo.somPorId(widget.idSom))
        : conteudo.somPorId(widget.idSom);
    final disponiveis =
        conteudo.catalogo.sonsAtivos.where((s) => s.disponivelOffline).toList();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, restricoes) => SingleChildScrollView(
            padding: Dimensoes.paddingTela,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: restricoes.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    CabecalhoVoltar(
                      acao: som != null && som.disponivelOffline
                          ? const ChipStatus(
                              icone: Icons.wifi_off,
                              texto: 'Offline',
                              cor: CoresSonoLeve.sucesso,
                            )
                          : null,
                    ),
                    const Spacer(),
                    AneisConcentricos(
                      largura: 262,
                      altura: 184,
                      child: IconeAneis(IconesConteudo.de(som?.icone ?? '')),
                    ),
                    const SizedBox(height: Dimensoes.espacoXxg),
                    Text(
                      som?.nome ?? 'Som indisponível',
                      textAlign: TextAlign.center,
                      style:
                          TipografiaSonoLeve.tituloTela.copyWith(fontSize: 29),
                    ),
                    const SizedBox(height: Dimensoes.espacoP),
                    Sobrelinha(
                      '${player.tocando ? 'Tocando' : 'Em pausa'} · ${som?.categoria ?? ''}',
                    ),
                    const SizedBox(height: Dimensoes.espacoXxg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BotaoCircular(
                          icone: Icons.skip_previous_rounded,
                          rotulo: 'Som anterior',
                          corFundo: Colors.transparent,
                          corIcone: CoresSonoLeve.textoSecundario,
                          aoTocar: disponiveis.length > 1
                              ? () => player.trocar(disponiveis, proximo: false)
                              : null,
                        ),
                        const SizedBox(width: Dimensoes.espacoXg),
                        BotaoCircular(
                          icone: player.tocando
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          rotulo: player.tocando ? 'Pausar' : 'Tocar',
                          tamanho: 80,
                          tamanhoIcone: 38,
                          corFundo: CoresSonoLeve.primaria,
                          corIcone: CoresSonoLeve.textoSobrePrimaria,
                          aoTocar:
                              som == null ? null : player.alternarReproducao,
                        ),
                        const SizedBox(width: Dimensoes.espacoXg),
                        BotaoCircular(
                          icone: Icons.skip_next_rounded,
                          rotulo: 'Próximo som',
                          corFundo: Colors.transparent,
                          corIcone: CoresSonoLeve.textoSecundario,
                          aoTocar: disponiveis.length > 1
                              ? () => player.trocar(disponiveis, proximo: true)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensoes.espacoXg),
                    Row(
                      children: [
                        const Icon(Icons.volume_down_rounded,
                            size: 20, color: CoresSonoLeve.textoSecundario),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              activeTrackColor: CoresSonoLeve.primaria,
                              inactiveTrackColor: CoresSonoLeve.borda,
                              thumbColor: CoresSonoLeve.primaria,
                              overlayColor: Colors.transparent,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 7),
                            ),
                            child: Slider(
                              value: player.volume,
                              onChanged: player.definirVolume,
                              semanticFormatterCallback: (v) =>
                                  'Volume ${(v * 100).round()}%',
                            ),
                          ),
                        ),
                        const Icon(Icons.volume_up_rounded,
                            size: 20, color: CoresSonoLeve.textoSecundario),
                      ],
                    ),
                    const SizedBox(height: Dimensoes.espacoXg),
                    BotaoContorno(
                      icone: Icons.timer_outlined,
                      texto: player.desligarEmMinutos == null
                          ? 'Desligar automaticamente'
                          : 'Desligar em ${player.desligarEmMinutos} min',
                      aoTocar: player.alternarDesligamento,
                    ),
                    const SizedBox(height: Dimensoes.espacoXxg),
                    const Text(
                      'Pode fechar os olhos. Fique à vontade.',
                      textAlign: TextAlign.center,
                      style: TipografiaSonoLeve.legenda,
                    ),
                    const SizedBox(height: Dimensoes.espacoP),
                    const Text(
                      'Protótipo: a reprodução de áudio é simulada.',
                      textAlign: TextAlign.center,
                      style: TipografiaSonoLeve.mini,
                    ),
                    const Spacer(),
                    const SizedBox(height: Dimensoes.espacoG),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
