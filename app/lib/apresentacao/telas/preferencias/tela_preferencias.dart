import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/tema/cores.dart';
import '../../../core/tema/dimensoes.dart';
import '../../../dominio/servicos/conectividade.dart';
import '../../../estado/auth_controller.dart';
import '../../../estado/checklist_controller.dart';
import '../../../estado/conteudo_controller.dart';
import '../../../estado/player_controller.dart';
import '../../../estado/preferencias_controller.dart';
import '../../../estado/registro_sono_controller.dart';
import '../../../injecao/dependencias.dart';
import '../../componentes/componentes.dart';

/// Preferências — `prototype/figma/08-preferencias.svg`.
class TelaPreferencias extends StatelessWidget {
  const TelaPreferencias({super.key});

  static const List<(String, String)> _horarios = [
    ('20:00', '05:00'),
    ('21:00', '06:00'),
    ('22:00', '07:00'),
    ('23:00', '07:00'),
  ];

  Future<void> _escolherAparencia(BuildContext context) async {
    final controller = context.read<PreferenciasController>();
    final atual = controller.preferencias;
    final automatica = await Dialogos.escolher<bool>(
      context,
      titulo: 'Aparência',
      selecionado: atual.temaAutomatico,
      opcoes: const [
        (true, 'Automática (acompanha o horário)'),
        (false, 'Sempre noturna'),
      ],
    );
    if (automatica != null) {
      await controller.atualizar(atual.copyWith(temaAutomatico: automatica));
    }
  }

  Future<void> _escolherHorario(BuildContext context) async {
    final controller = context.read<PreferenciasController>();
    final atual = controller.preferencias;
    final escolhido = await Dialogos.escolher<(String, String)>(
      context,
      titulo: 'Seu horário noturno',
      selecionado: (atual.horaInicioNoite, atual.horaFimNoite),
      opcoes: [for (final h in _horarios) (h, '${h.$1} — ${h.$2}')],
    );
    if (escolhido != null) {
      await controller.atualizar(
        atual.copyWith(
            horaInicioNoite: escolhido.$1, horaFimNoite: escolhido.$2),
      );
    }
  }

  /// Limpa o estado em memória e volta à raiz antes de trocar a sessão.
  void _encerrarSessaoLocal(BuildContext context) {
    context.read<PlayerController>().pausar();
    context.read<RegistroSonoController>().limpar();
    context.read<PreferenciasController>().limpar();
    context.read<ChecklistController>().limpar();
    Navigator.of(context).popUntil((rota) => rota.isFirst);
  }

  Future<void> _sair(BuildContext context) async {
    final auth = context.read<AuthController>();
    final confirmado = await Dialogos.confirmar(
      context,
      titulo: 'Sair da conta?',
      mensagem: 'Seus registros continuam guardados na sua conta.',
      textoConfirmar: 'Sair',
    );
    if (!confirmado || !context.mounted) return;
    _encerrarSessaoLocal(context);
    await auth.sair();
  }

  Future<void> _excluirDados(BuildContext context) async {
    final auth = context.read<AuthController>();
    final confirmado = await Dialogos.confirmar(
      context,
      titulo: 'Excluir meus dados?',
      mensagem:
          'Sua conta, seus registros de sono e suas preferências serão apagados. '
          'Isso não pode ser desfeito.',
      textoConfirmar: 'Excluir tudo',
    );
    if (!confirmado || !context.mounted) return;
    final erro = await auth.excluirMeusDados();
    if (!context.mounted) return;
    if (erro != null) {
      Dialogos.mensagem(context, erro);
      return;
    }
    _encerrarSessaoLocal(context);
  }

  @override
  Widget build(BuildContext context) {
    final preferencias = context.watch<PreferenciasController>().preferencias;
    final catalogo = context.watch<ConteudoController>().catalogo;
    final usuario = context.watch<AuthController>().usuario;
    final online = context.watch<Conectividade>().online;
    final simulada = context.read<Dependencias>().conectividadeSimulada;
    final sons = catalogo.sonsAtivos;
    final sonsOffline = sons.where((s) => s.disponivelOffline).length;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Dimensoes.paddingTela,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CabecalhoVoltar(),
              const SizedBox(height: Dimensoes.espacoP),
              const TituloTela('Do seu jeito.',
                  subtitulo: 'O SonoLeve acompanha o seu descanso.'),
              const SizedBox(height: Dimensoes.espacoP),
              LinhaPreferencia(
                titulo: 'Aparência',
                valor: preferencias.temaAutomatico
                    ? 'Automática'
                    : 'Sempre noturna',
                trailing: const Icon(Icons.expand_more,
                    color: CoresSonoLeve.textoSecundario),
                aoTocar: () => _escolherAparencia(context),
              ),
              LinhaPreferencia(
                titulo: 'Seu horário noturno',
                valor:
                    '${preferencias.horaInicioNoite} — ${preferencias.horaFimNoite}',
                trailing: const Icon(Icons.expand_more,
                    color: CoresSonoLeve.textoSecundario),
                aoTocar: () => _escolherHorario(context),
              ),
              LinhaPreferencia(
                titulo: 'Reduzir movimento',
                valor: preferencias.reduzirMovimento ? 'Ativado' : 'Desativado',
                trailing: AlternadorSuave(
                  rotulo: 'Reduzir movimento',
                  ativo: preferencias.reduzirMovimento,
                  aoMudar: (valor) => context
                      .read<PreferenciasController>()
                      .atualizar(
                          preferencias.copyWith(reduzirMovimento: valor)),
                ),
              ),
              LinhaPreferencia(
                titulo: 'Sons e respiração offline',
                valor: sonsOffline == sons.length
                    ? 'Disponíveis'
                    : '$sonsOffline de ${sons.length} sons baixados',
                trailing: const Icon(Icons.wifi_off,
                    color: CoresSonoLeve.textoSecundario),
              ),
              const LinhaPreferencia(
                titulo: 'Seus dados são só seus',
                valor:
                    'Sem microfone ou sensores. Registros protegidos na sua conta.',
                trailing: Icon(Icons.shield_outlined,
                    color: CoresSonoLeve.textoSecundario),
              ),
              if (simulada != null)
                LinhaPreferencia(
                  titulo: 'Simular modo offline',
                  valor: 'Protótipo — teste o app sem internet',
                  trailing: AlternadorSuave(
                    rotulo: 'Simular modo offline',
                    ativo: !online,
                    aoMudar: (offline) => simulada.definir(online: !offline),
                  ),
                ),
              LinhaPreferencia(
                titulo: 'Sair da conta',
                valor: usuario?.email ?? '',
                trailing: const Icon(Icons.logout,
                    color: CoresSonoLeve.textoSecundario),
                aoTocar: () => _sair(context),
              ),
              LinhaPreferencia(
                titulo: 'Excluir meus dados',
                valor: 'Apaga sua conta e seus registros',
                corTitulo: CoresSonoLeve.destaque,
                trailing: const Icon(Icons.delete_outline,
                    color: CoresSonoLeve.destaque),
                aoTocar: () => _excluirDados(context),
              ),
              const SizedBox(height: Dimensoes.espacoXg),
              const CartaoDica(
                titulo: 'A interface muda suavemente com o horário.',
                texto: 'À noite, sempre com pouca luz.',
              ),
              const SizedBox(height: Dimensoes.espacoXg),
              BotaoPrimario(
                  texto: 'Concluir',
                  aoTocar: () => Navigator.of(context).maybePop()),
              const SizedBox(height: Dimensoes.espacoXg),
            ],
          ),
        ),
      ),
    );
  }
}
