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

/// Exercício de respiração 4–7–8.
/// Referência do Figma: 14:249 (05-Respiracao-Inspirar).
/// A lógica de tempo, ciclos e pausa por encerramento é do controller existente.
class TelaRespiracao extends StatelessWidget {
  const TelaRespiracao({super.key, this.idTecnica});

  final String? idTecnica;

  @override
  Widget build(BuildContext context) {
    final sessao = context.select<ConteudoController, SessaoRespiracao?>(
      (conteudo) => conteudo.respiracaoPorId(idTecnica),
    );

    if (sessao == null) {
      return const Scaffold(
        body: SafeArea(
          child: Center(child: EstadoCarregando()),
        ),
      );
    }

    // Cada abertura da tela tem seu próprio temporizador; ao voltar, ele
    // é descartado pelo Provider, sem deixar contagem rodando em segundo plano.
    return ChangeNotifierProvider<RespiracaoController>(
      key: ValueKey(sessao.id),
      create: (_) => RespiracaoController(sessao),
      child: const _ConteudoRespiracao(),
    );
  }
}

class _ConteudoRespiracao extends StatelessWidget {
  const _ConteudoRespiracao();

  static String _nomeFase(FaseRespiracao fase) => switch (fase) {
        FaseRespiracao.pronta || FaseRespiracao.inspirar => 'Inspire',
        FaseRespiracao.segurar => 'Segure',
        FaseRespiracao.expirar => 'Expire',
        FaseRespiracao.concluida => 'Muito bem',
      };

  static double _escalaAlvo(FaseRespiracao fase) => switch (fase) {
        FaseRespiracao.inspirar || FaseRespiracao.segurar => 1,
        FaseRespiracao.expirar => 0,
        _ => 0.5,
      };

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RespiracaoController>();
    final reduzirMovimento = context.select<PreferenciasController, bool>(
      (p) => p.preferencias.reduzirMovimento,
    );
    final sessao = controller.sessao;
    final fase = controller.fase;
    final legendaCentral = fase == FaseRespiracao.concluida
        ? '${sessao.ciclos} ciclos concluídos'
        : '${controller.segundosRestantes} segundos';

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, restricoes) => SingleChildScrollView(
            padding: Dimensoes.paddingTela,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: restricoes.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CabecalhoVoltar(),
                        SizedBox(height: Dimensoes.espacoP),
                        TituloTela('Um respiro.\nUm pouco de calma.'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
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
                              label: '${_nomeFase(fase)}. $legendaCentral',
                              child: ExcludeSemantics(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.air,
                                      size: 18,
                                      color: CoresSonoLeve.lavanda,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _nomeFase(fase),
                                      style: TipografiaSonoLeve.numeroGrande,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      legendaCentral,
                                      style: TipografiaSonoLeve.legenda.copyWith(
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
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
                              ativa: fase == FaseRespiracao.inspirar,
                            ),
                            _Etapa(
                              numero: sessao.segurarSeg,
                              rotulo: 'segure',
                              ativa: fase == FaseRespiracao.segurar,
                            ),
                            _Etapa(
                              numero: sessao.expirarSeg,
                              rotulo: 'expire',
                              ativa: fase == FaseRespiracao.expirar,
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensoes.espacoXg),
                        Text(
                          controller.emAndamento
                              ? 'Ciclo ${controller.cicloAtual} de ${sessao.ciclos}'
                              : fase == FaseRespiracao.concluida
                                  ? 'Você terminou seu momento de calma.'
                                  : 'Acompanhe a forma, sem forçar.\nPare quando quiser.',
                          textAlign: TextAlign.center,
                          style: TipografiaSonoLeve.corpo,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: Dimensoes.espacoG),
                    child: Column(
                      children: [
                        BotaoPrimario(
                          texto: controller.emAndamento
                              ? 'Parar'
                              : fase == FaseRespiracao.concluida
                                  ? 'Respirar de novo'
                                  : 'Começar a respirar',
                          aoTocar: controller.emAndamento
                              ? controller.parar
                              : controller.iniciar,
                        ),
                        const SizedBox(height: Dimensoes.espacoM),
                        const NotaRodape(
                          icone: Icons.wifi_off,
                          texto: 'Funciona sem internet.',
                        ),
                      ],
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

class _Etapa extends StatelessWidget {
  const _Etapa({
    required this.numero,
    required this.rotulo,
    required this.ativa,
  });

  final int numero;
  final String rotulo;
  final bool ativa;

  @override
  Widget build(BuildContext context) {
    final cor = ativa ? CoresSonoLeve.lavanda : CoresSonoLeve.textoSecundario;
    return Expanded(
      child: Semantics(
        label: '$numero segundos para $rotulo${ativa ? ', etapa atual' : ''}',
        child: ExcludeSemantics(
          child: Column(
            children: [
              Text(
                '$numero',
                style: TipografiaSonoLeve.numeroGrande.copyWith(
                  fontSize: 25,
                  color: cor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                rotulo,
                style: TipografiaSonoLeve.legenda.copyWith(color: cor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
