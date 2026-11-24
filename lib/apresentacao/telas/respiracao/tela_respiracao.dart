import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/tema/cores.dart';
import '../../../core/tema/dimensoes.dart';
import '../../../core/tema/tipografia.dart';
import '../../../dominio/modelos/conteudo.dart';
import '../../../estado/conteudo_controller.dart';
import '../../../estado/preferencias_controller.dart';
import '../../../estado/respiracao_controller.dart';
import '../../componentes/componentes.dart';

/// Respiração guiada 4-7-8 — `prototype/figma/05-respiracao.svg`.
class TelaRespiracao extends StatelessWidget {
  const TelaRespiracao({super.key, this.idTecnica});

  final String? idTecnica;

  @override
  Widget build(BuildContext context) {
    final sessao = context.select<ConteudoController, SessaoRespiracao?>(
      (c) => c.respiracaoPorId(idTecnica),
    );
    if (sessao == null) {
      return const Scaffold(body: SafeArea(child: EstadoCarregando()));
    }
    // Um controller por sessão: o timer é encerrado ao sair da tela.
    return ChangeNotifierProvider<RespiracaoController>(
      key: ValueKey(sessao.id),
      create: (_) => RespiracaoController(sessao),
      child: const _ConteudoRespiracao(),
    );
  }
}

class _ConteudoRespiracao extends StatelessWidget {
  const _ConteudoRespiracao();

  static String _titulo(FaseRespiracao fase) => switch (fase) {
        FaseRespiracao.pronta || FaseRespiracao.inspirar => 'Inspire',
        FaseRespiracao.segurar => 'Segure',
        FaseRespiracao.expirar => 'Expire',
        FaseRespiracao.concluida => 'Muito bem',
      };

  /// Anéis expandem ao inspirar, ficam abertos ao segurar e recolhem ao expirar.
  static double _escalaAlvo(FaseRespiracao fase) => switch (fase) {
        FaseRespiracao.inspirar || FaseRespiracao.segurar => 1,
        FaseRespiracao.expirar => 0,
        _ => 0.5,
      };

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RespiracaoController>();
    final reduzirMovimento = context.select<PreferenciasController, bool>(
        (p) => p.preferencias.reduzirMovimento);
    final sessao = controller.sessao;
    final fase = controller.fase;

    final subtitulo = switch (fase) {
      FaseRespiracao.concluida => '${sessao.ciclos} ciclos concluídos',
      _ => '${controller.segundosRestantes} segundos',
    };

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, restricoes) => SingleChildScrollView(
            padding: Dimensoes.paddingTela,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: restricoes.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CabecalhoVoltar(),
                    const SizedBox(height: Dimensoes.espacoP),
                    const TituloTela('Um respiro.\nUm pouco de calma.'),
                    const Spacer(),
                    Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0.5,
                          end: reduzirMovimento ? 1 : _escalaAlvo(fase),
                        ),
                        duration: Duration(
                          seconds: reduzirMovimento
                              ? 0
                              : controller.duracaoDa(fase).clamp(1, 12).toInt(),
                        ),
                        curve: Curves.easeInOut,
                        builder: (context, escala, filho) =>
                            AneisConcentricos(escala: escala, child: filho),
                        child: Semantics(
                          liveRegion: true,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.air,
                                  size: 18, color: CoresSonoLeve.lavanda),
                              const SizedBox(height: 2),
                              Text(_titulo(fase),
                                  style: TipografiaSonoLeve.numeroGrande),
                              const SizedBox(height: 2),
                              Text(
                                subtitulo,
                                style: TipografiaSonoLeve.legenda
                                    .copyWith(letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensoes.espacoXxg),
                    Row(
                      children: [
                        _Etapa(
                            numero: sessao.inspirarSeg,
                            rotulo: 'inspire',
                            ativa: fase == FaseRespiracao.inspirar),
                        _Etapa(
                            numero: sessao.segurarSeg,
                            rotulo: 'segure',
                            ativa: fase == FaseRespiracao.segurar),
                        _Etapa(
                            numero: sessao.expirarSeg,
                            rotulo: 'expire',
                            ativa: fase == FaseRespiracao.expirar),
                      ],
                    ),
                    const SizedBox(height: Dimensoes.espacoXg),
                    Center(
                      child: Text(
                        controller.emAndamento
                            ? 'Ciclo ${controller.cicloAtual} de ${sessao.ciclos}'
                            : 'Acompanhe a forma, sem forçar.\nPare quando quiser.',
                        textAlign: TextAlign.center,
                        style: TipografiaSonoLeve.corpo,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: Dimensoes.espacoXg),
                    BotaoPrimario(
                      texto: controller.emAndamento
                          ? 'Parar'
                          : (fase == FaseRespiracao.concluida
                              ? 'Respirar de novo'
                              : 'Começar a respirar'),
                      aoTocar: controller.emAndamento
                          ? controller.parar
                          : controller.iniciar,
                    ),
                    const SizedBox(height: Dimensoes.espacoM),
                    const NotaRodape(
                        icone: Icons.wifi_off, texto: 'Funciona sem internet.'),
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

class _Etapa extends StatelessWidget {
  const _Etapa(
      {required this.numero, required this.rotulo, required this.ativa});

  final int numero;
  final String rotulo;
  final bool ativa;

  @override
  Widget build(BuildContext context) {
    final cor = ativa ? CoresSonoLeve.lavanda : CoresSonoLeve.textoSecundario;
    return Expanded(
      child: Column(
        children: [
          Text('$numero',
              style: TipografiaSonoLeve.numeroGrande
                  .copyWith(fontSize: 25, color: cor)),
          const SizedBox(height: 4),
          Text(rotulo, style: TipografiaSonoLeve.legenda.copyWith(color: cor)),
        ],
      ),
    );
  }
}
