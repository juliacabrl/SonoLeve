import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/rotas/rotas.dart';
import '../../../core/tema/cores.dart';
import '../../../core/tema/dimensoes.dart';
import '../../../core/tema/tipografia.dart';
import '../../../dominio/modelos/conteudo.dart';
import '../../../dominio/servicos/conectividade.dart';
import '../../../estado/conteudo_controller.dart';
import '../../componentes/componentes.dart';
import '../comum/selo_conexao.dart';

/// Aba "Relaxar" — `prototype/figma/03-sons.svg`.
class TelaRelaxar extends StatelessWidget {
  const TelaRelaxar({super.key});

  Future<void> _abrirSom(BuildContext context, Som som) async {
    final navegador = Navigator.of(context);
    if (som.disponivelOffline) {
      await navegador.pushNamed(Rotas.player, arguments: som.id);
      return;
    }
    // Som novo do catálogo, ainda não baixado (item a.iv — falha de conexão).
    if (!context.read<Conectividade>().online) {
      Dialogos.mensagem(
          context, 'Este som fica disponível quando você estiver conectado.');
      return;
    }
    final erro = await context.read<ConteudoController>().baixarSom(som);
    if (!context.mounted) return;
    if (erro != null) {
      Dialogos.mensagem(context, erro);
    } else {
      await navegador.pushNamed(Rotas.player, arguments: som.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final conteudo = context.watch<ConteudoController>();
    final online = context.watch<Conectividade>().online;
    final catalogo = conteudo.catalogo;

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
                  Expanded(child: Sobrelinha('Seu momento')),
                  SeloConexao(),
                ],
              ),
            ),
            const SizedBox(height: Dimensoes.espacoM),
            const TituloTela('Encontre o\nseu silêncio.'),
            const SizedBox(height: Dimensoes.espacoXg),
            const Text('Escolha um som. O resto pode esperar.',
                style: TipografiaSonoLeve.corpo),
            const SizedBox(height: Dimensoes.espacoG),
            if (conteudo.carregando)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: Dimensoes.espacoXxg),
                child: EstadoCarregando(mensagem: 'Preparando os sons…'),
              )
            else ...[
              for (final som in catalogo.sonsAtivos) ...[
                CartaoNavegavel(
                  icone: IconesConteudo.de(som.icone),
                  titulo: som.nome,
                  descricao: som.disponivelOffline
                      ? som.descricao
                      : (online
                          ? 'Novo · toque para baixar'
                          : 'Disponível quando conectado'),
                  indicador: _indicadorSom(conteudo, som, online),
                  aoTocar: () => _abrirSom(context, som),
                ),
                const SizedBox(height: Dimensoes.espacoM),
              ],
              const SizedBox(height: Dimensoes.espacoP),
              for (final tecnica in catalogo.respiracoesAtivas) ...[
                CartaoNavegavel(
                  comCirculo: false,
                  icone: IconesConteudo.de('respiracao'),
                  titulo: tecnica.nome,
                  descricao: tecnica.descricao,
                  aoTocar: () => Navigator.of(context)
                      .pushNamed(Rotas.respiracao, arguments: tecnica.id),
                ),
                const SizedBox(height: Dimensoes.espacoM),
              ],
            ],
            const SizedBox(height: Dimensoes.espacoG),
            const NotaRodape(
              icone: Icons.headphones_outlined,
              texto: 'Comece com um volume confortável.',
            ),
            if (conteudo.sincronizando) ...[
              const SizedBox(height: Dimensoes.espacoM),
              const Center(
                  child: Text('Buscando novidades…',
                      style: TipografiaSonoLeve.mini)),
            ],
            const SizedBox(height: Dimensoes.espacoXg),
          ],
        ),
      ),
    );
  }

  Widget? _indicadorSom(ConteudoController conteudo, Som som, bool online) {
    if (som.disponivelOffline) return null; // seta padrão
    if (conteudo.estaBaixando(som.id)) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
            strokeWidth: 2, color: CoresSonoLeve.lavanda),
      );
    }
    return Icon(
      online ? Icons.file_download_outlined : Icons.cloud_off_outlined,
      size: 20,
      color: CoresSonoLeve.textoSecundario,
    );
  }
}
