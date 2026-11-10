import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/rotas/rotas.dart';
import '../../../core/tema/dimensoes.dart';
import '../../../core/tema/tipografia.dart';
import '../../../core/utils/formatadores.dart';
import '../../../dominio/modelos/registro_sono.dart';
import '../../../estado/conteudo_controller.dart';
import '../../../estado/registro_sono_controller.dart';
import '../../componentes/componentes.dart';

/// Aba "Diário" — `prototype/figma/06-diario.svg`.
class TelaDiario extends StatelessWidget {
  const TelaDiario({super.key});

  static const int _noitesNaLista = 3;

  @override
  Widget build(BuildContext context) {
    final diario = context.watch<RegistroSonoController>();
    final dica = context.watch<ConteudoController>().dicaDoDia();
    final hoje = DateTime.now();
    final resumo = diario.resumo(hoje);
    final recentes = diario.registros.take(_noitesNaLista).toList();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: Dimensoes.paddingTela,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: Dimensoes.espacoG),
            const SizedBox(
              height: 40,
              child: Row(
                children: [
                  Expanded(child: Sobrelinha('Diário do sono')),
                  ChipStatus(icone: Icons.lock_outline, texto: 'Só seu'),
                ],
              ),
            ),
            const SizedBox(height: Dimensoes.espacoM),
            const TituloTela('Cada noite\nconta uma história.'),
            const SizedBox(height: Dimensoes.espacoXg),
            GraficoSemanal(
              titulo: 'Média dos últimos 7 dias',
              valorPrincipal: resumo.quantidadeNoites == 0
                  ? '—'
                  : Formatadores.duracaoMedia(resumo.mediaMinutos),
              detalhe: Formatadores.contagem(
                  resumo.quantidadeNoites, 'noite', 'noites'),
              barras: [
                for (final dia in resumo.dias)
                  BarraGrafico(
                    rotulo: Formatadores.diaSemanaCurto(dia),
                    minutos: resumo.registroDo(dia)?.minutosDormidos,
                    destaque: dia == resumo.fimSemana,
                  ),
              ],
            ),
            const SizedBox(height: Dimensoes.espacoG),
            BotaoPrimario(
              icone: Icons.add,
              texto: 'Registrar minha noite',
              aoTocar: () => Navigator.of(context).pushNamed(Rotas.registrar),
            ),
            const SizedBox(height: Dimensoes.espacoXg),
            Row(
              children: [
                const Expanded(
                    child: Text('Suas noites',
                        style: TipografiaSonoLeve.subtitulo)),
                BotaoTexto(
                  texto: 'Ver histórico',
                  aoTocar: () =>
                      Navigator.of(context).pushNamed(Rotas.historico),
                ),
              ],
            ),
            if (diario.carregando && diario.registros.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: Dimensoes.espacoXg),
                child: EstadoCarregando(),
              )
            else if (diario.erroCarregamento != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: Dimensoes.espacoG),
                child: AvisoEmLinha(mensagem: diario.erroCarregamento!),
              )
            else if (recentes.isEmpty)
              const EstadoVazio(
                icone: Icons.nights_stay_outlined,
                mensagem:
                    'Nenhuma noite registrada ainda.\nQue tal começar pela de hoje?',
              )
            else
              for (final registro in recentes)
                LinhaRegistroSono(registro: registro),
            if (dica != null) ...[
              const SizedBox(height: Dimensoes.espacoXg),
              CartaoDica(titulo: dica.titulo, texto: dica.conteudo),
            ],
            const SizedBox(height: Dimensoes.espacoXg),
          ],
        ),
      ),
    );
  }
}

/// Liga um [RegistroSono] ao componente visual e abre a edição ao tocar.
class LinhaRegistroSono extends StatelessWidget {
  const LinhaRegistroSono({super.key, required this.registro});

  final RegistroSono registro;

  @override
  Widget build(BuildContext context) {
    return LinhaRegistro(
      titulo: Formatadores.dataCurta(registro.data),
      subtitulo:
          '${Formatadores.duracaoCurta(registro.minutosDormidos)} de descanso',
      estrelas: registro.qualidade,
      aoTocar: () =>
          Navigator.of(context).pushNamed(Rotas.registrar, arguments: registro),
    );
  }
}
