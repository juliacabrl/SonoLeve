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

/// Tela "Encontre o seu silêncio", integrada à aba Relaxar do ShellPrincipal.
/// Referência do Figma: 14:91 (03-Sons-icones-refinados).
/// Reutiliza o catálogo, o player, as rotas e os componentes do SonoLeve.
class TelaRelaxar extends StatelessWidget {
  const TelaRelaxar({super.key});

  Future<void> _abrirSom(BuildContext context, Som som) async {
    final navegador = Navigator.of(context);
    final conteudo = context.read<ConteudoController>();

    if (som.disponivelOffline) {
      await navegador.pushNamed(Rotas.player, arguments: som.id);
      return;
    }

    if (!context.read<Conectividade>().online) {
      Dialogos.mensagem(
        context,
        'Este som fica disponível quando você estiver conectado.',
      );
      return;
    }

    final erro = await conteudo.baixarSom(som);
    if (!context.mounted) return;
    if (erro != null) {
      Dialogos.mensagem(context, erro);
      return;
    }

    await navegador.pushNamed(Rotas.player, arguments: som.id);
  }

  @override
  Widget build(BuildContext context) {
    final conteudo = context.watch<ConteudoController>();
    final online = context.watch<Conectividade>().online;
    final sons = conteudo.catalogo.sonsAtivos;
    final tecnicas = conteudo.catalogo.respiracoesAtivas;

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
            const Text(
              'Escolha um som. O resto pode esperar.',
              style: TipografiaSonoLeve.corpo,
            ),
            const SizedBox(height: Dimensoes.espacoG),
            if (conteudo.carregando)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: Dimensoes.espacoXxg),
                child: EstadoCarregando(mensagem: 'Preparando os sons…'),
              )
            else ...[
              for (final som in sons) ...[
                CartaoNavegavel(
                  icone: IconesConteudo.de(som.icone),
                  titulo: som.nome,
                  descricao: som.disponivelOffline
                      ? som.descricao
                      : (online
                          ? 'Novo · toque para baixar'
                          : 'Disponível quando conectado'),
                  indicador: _indicadorSom(conteudo, som, online),
                  aoTocar: conteudo.estaBaixando(som.id)
                      ? null
                      : () => _abrirSom(context, som),
                ),
                const SizedBox(height: Dimensoes.espacoM),
              ],
              if (sons.isEmpty && tecnicas.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: Dimensoes.espacoXxg),
                  child: Text(
                    'Ainda não há conteúdos disponíveis.',
                    style: TipografiaSonoLeve.corpo,
                  ),
                ),
              if (tecnicas.isNotEmpty)
                const SizedBox(height: Dimensoes.espacoP),
              for (final tecnica in tecnicas) ...[
                CartaoNavegavel(
                  comCirculo: false,
                  icone: IconesConteudo.de('respiracao'),
                  titulo: tecnica.nome,
                  descricao: tecnica.descricao,
                  aoTocar: () => Navigator.of(context).pushNamed(
                    Rotas.respiracao,
                    arguments: tecnica.id,
                  ),
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
                child: Text(
                  'Buscando novidades…',
                  style: TipografiaSonoLeve.mini,
                ),
              ),
            ],
            const SizedBox(height: Dimensoes.espacoXg),
          ],
        ),
      ),
    );
  }

  Widget? _indicadorSom(
    ConteudoController conteudo,
    Som som,
    bool online,
  ) {
    if (som.disponivelOffline) return null;
    if (conteudo.estaBaixando(som.id)) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: CoresSonoLeve.lavanda,
        ),
      );
    }
    return Icon(
      online ? Icons.file_download_outlined : Icons.cloud_off_outlined,
      size: 20,
      color: CoresSonoLeve.textoSecundario,
    );
  }
}
