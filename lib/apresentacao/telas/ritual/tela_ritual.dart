import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/tema/dimensoes.dart';
import '../../../core/tema/tipografia.dart';
import '../../../estado/checklist_controller.dart';
import '../../../estado/conteudo_controller.dart';
import '../../../estado/navegacao_controller.dart';
import '../../componentes/componentes.dart';

/// Ritual noturno (checklist) — `prototype/figma/02-ritual.svg`.
///
/// Os hábitos vêm do catálogo; o progresso fica só no dispositivo (RN07).
class TelaRitual extends StatefulWidget {
  const TelaRitual({super.key});

  @override
  State<TelaRitual> createState() => _TelaRitualState();
}

class _TelaRitualState extends State<TelaRitual> {
  @override
  void initState() {
    super.initState();
    // Se o app ficou aberto de um dia para o outro, começa um checklist novo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ChecklistController>().carregar(DateTime.now());
    });
  }

  /// Volta às abas principais (o ritual mantém a barra inferior visível).
  void _irParaAba(AbaPrincipal aba) {
    context.read<NavegacaoController>().ir(aba);
    Navigator.of(context).popUntil((rota) => rota.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final conteudo = context.watch<ConteudoController>();
    final checklist = context.watch<ChecklistController>().checklist;
    final ativos = conteudo.catalogo.habitosAtivos;
    final concluidos = checklist?.concluidosEntre(ativos) ?? 0;
    final completo = ativos.isNotEmpty && concluidos == ativos.length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: Dimensoes.paddingTela,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CabecalhoVoltar(),
              const SizedBox(height: Dimensoes.espacoP),
              const TituloTela('Seu ritual,\nno seu tempo.'),
              const SizedBox(height: Dimensoes.espacoXg),
              const Text('Pequenos cuidados para encerrar o dia.',
                  style: TipografiaSonoLeve.corpo),
              const SizedBox(height: Dimensoes.espacoP),
              Row(
                children: [
                  const Expanded(
                      child: Text('Hoje, sem pressa',
                          style: TipografiaSonoLeve.legenda)),
                  Text('$concluidos de ${ativos.length}',
                      style: TipografiaSonoLeve.legenda),
                ],
              ),
              const SizedBox(height: Dimensoes.espacoP),
              BarraProgresso(valor: checklist?.progresso(ativos) ?? 0),
              const SizedBox(height: Dimensoes.espacoXg),
              if (checklist == null || conteudo.carregando)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: Dimensoes.espacoXg),
                  child: EstadoCarregando(),
                )
              else
                for (final habito in ativos) ...[
                  ItemChecklist(
                    titulo: habito.titulo,
                    concluido: checklist.estaConcluido(habito.id),
                    aoTocar: () =>
                        context.read<ChecklistController>().alternar(habito.id),
                  ),
                  const SizedBox(height: Dimensoes.espacoM),
                ],
              const SizedBox(height: Dimensoes.espacoM),
              CartaoDica(
                titulo: completo
                    ? 'Ritual completo.'
                    : 'Um pequeno cuidado já é um começo.',
                texto: completo
                    ? 'Agora é só descansar.'
                    : 'Não precisa fazer tudo hoje.',
              ),
              const SizedBox(height: Dimensoes.espacoXg),
              BotaoPrimario(
                texto: 'Agora, relaxar',
                aoTocar: () => _irParaAba(AbaPrincipal.relaxar),
              ),
              const SizedBox(height: Dimensoes.espacoXg),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BarraNavegacaoSonoLeve(
        abaAtual: AbaPrincipal.hoje,
        aoSelecionar: _irParaAba,
      ),
    );
  }
}
