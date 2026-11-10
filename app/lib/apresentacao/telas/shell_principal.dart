import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../estado/auth_controller.dart';
import '../../estado/checklist_controller.dart';
import '../../estado/conteudo_controller.dart';
import '../../estado/navegacao_controller.dart';
import '../../estado/preferencias_controller.dart';
import '../../estado/registro_sono_controller.dart';
import '../componentes/componentes.dart';
import 'diario/tela_diario.dart';
import 'hoje/tela_hoje.dart';
import 'relaxar/tela_relaxar.dart';

/// Casca do app autenticado: as três abas e a barra inferior.
class ShellPrincipal extends StatefulWidget {
  const ShellPrincipal({super.key});

  @override
  State<ShellPrincipal> createState() => _ShellPrincipalState();
}

class _ShellPrincipalState extends State<ShellPrincipal> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarDados());
  }

  void _carregarDados() {
    if (!mounted) return;
    final uid = context.read<AuthController>().usuario?.uid;
    if (uid == null) return;
    context.read<NavegacaoController>().ir(AbaPrincipal.hoje);
    context.read<ConteudoController>().iniciar();
    context.read<RegistroSonoController>().carregar(uid);
    context.read<PreferenciasController>().carregar(uid);
    context.read<ChecklistController>().carregar(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final navegacao = context.watch<NavegacaoController>();
    return Scaffold(
      body: IndexedStack(
        index: navegacao.aba.index,
        children: const [TelaHoje(), TelaRelaxar(), TelaDiario()],
      ),
      bottomNavigationBar: BarraNavegacaoSonoLeve(
        abaAtual: navegacao.aba,
        aoSelecionar: navegacao.ir,
      ),
    );
  }
}
