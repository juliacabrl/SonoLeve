import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/tema/dimensoes.dart';
import '../../../core/utils/formatadores.dart';
import '../../../estado/registro_sono_controller.dart';
import '../../componentes/componentes.dart';
import 'tela_diario.dart';

/// Histórico completo do diário (RF08). Tela nova, sem protótipo no Figma:
/// reutiliza os componentes da aba Diário.
class TelaHistorico extends StatelessWidget {
  const TelaHistorico({super.key});

  @override
  Widget build(BuildContext context) {
    final registros = context.watch<RegistroSonoController>().registros;
    final quantidade = Formatadores.contagem(
        registros.length, 'noite registrada', 'noites registradas');

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: Dimensoes.paddingTela,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const CabecalhoVoltar(),
                  const SizedBox(height: Dimensoes.espacoP),
                  TituloTela(
                    'Suas noites',
                    subtitulo: registros.isEmpty
                        ? 'Quando você registrar uma noite, ela aparece aqui.'
                        : '$quantidade. Toque em uma para editar ou excluir.',
                  ),
                  const SizedBox(height: Dimensoes.espacoG),
                  if (registros.isEmpty)
                    const EstadoVazio(
                      icone: Icons.nights_stay_outlined,
                      mensagem: 'Nenhuma noite registrada ainda.',
                    ),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(Dimensoes.margemTela, 0,
                  Dimensoes.margemTela, Dimensoes.espacoXg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, indice) =>
                      LinhaRegistroSono(registro: registros[indice]),
                  childCount: registros.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
