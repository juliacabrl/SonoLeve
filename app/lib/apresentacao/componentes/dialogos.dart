import 'package:flutter/material.dart';

import '../../core/tema/cores.dart';
import '../../core/tema/dimensoes.dart';
import '../../core/tema/tipografia.dart';

/// Diálogos e mensagens com o visual do SonoLeve.
abstract final class Dialogos {
  /// Pede confirmação para ações destrutivas (excluir registro, excluir dados).
  static Future<bool> confirmar(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    required String textoConfirmar,
    String textoCancelar = 'Cancelar',
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        backgroundColor: CoresSonoLeve.superficie,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensoes.raioGrande)),
        title: Text(titulo, style: TipografiaSonoLeve.tituloCartao),
        content: Text(mensagem, style: TipografiaSonoLeve.corpo),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(false),
            child: Text(textoCancelar, style: TipografiaSonoLeve.corpoForte),
          ),
          TextButton(
            onPressed: () => Navigator.of(contexto).pop(true),
            child: Text(
              textoConfirmar,
              style: TipografiaSonoLeve.corpoForte
                  .copyWith(color: CoresSonoLeve.destaque),
            ),
          ),
        ],
      ),
    );
    return resultado ?? false;
  }

  /// Mensagem breve no rodapé da tela.
  static void mensagem(BuildContext context, String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  /// Lista de opções em uma folha inferior (bottom sheet).
  static Future<T?> escolher<T>(
    BuildContext context, {
    required String titulo,
    required List<(T valor, String rotulo)> opcoes,
    T? selecionado,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      builder: (contexto) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimensoes.margemTela, 0, Dimensoes.margemTela, Dimensoes.espacoG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: TipografiaSonoLeve.tituloCartao),
              const SizedBox(height: Dimensoes.espacoP),
              for (final (valor, rotulo) in opcoes)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(rotulo, style: TipografiaSonoLeve.corpoForte),
                  trailing: valor == selecionado
                      ? const Icon(Icons.check_rounded,
                          color: CoresSonoLeve.sucesso)
                      : null,
                  onTap: () => Navigator.of(contexto).pop(valor),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
