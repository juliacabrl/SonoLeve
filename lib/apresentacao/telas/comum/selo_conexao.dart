import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/tema/cores.dart';
import '../../../dominio/servicos/conectividade.dart';
import '../../componentes/componentes.dart';

/// Selo "Offline" exibido quando o aparelho está sem internet — avisa, sem
/// alarme, que o app segue funcionando com o conteúdo guardado.
class SeloConexao extends StatelessWidget {
  const SeloConexao({super.key});

  @override
  Widget build(BuildContext context) {
    final online = context.watch<Conectividade>().online;
    if (online) return const SizedBox.shrink();
    return const ChipStatus(
      icone: Icons.wifi_off,
      texto: 'Offline',
      cor: CoresSonoLeve.sucesso,
    );
  }
}
