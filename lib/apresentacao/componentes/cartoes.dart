import 'package:flutter/material.dart';

import '../../core/tema/cores.dart';
import '../../core/tema/dimensoes.dart';
import '../../core/tema/tipografia.dart';

/// Superfície básica de cartão, opcionalmente tocável.
class Cartao extends StatelessWidget {
  const Cartao({
    super.key,
    required this.child,
    this.aoTocar,
    this.padding = const EdgeInsets.all(Dimensoes.espacoG),
    this.raio = Dimensoes.raioCartao,
    this.rotuloSemantico,
  });

  final Widget child;
  final VoidCallback? aoTocar;
  final EdgeInsetsGeometry padding;
  final double raio;
  final String? rotuloSemantico;

  @override
  Widget build(BuildContext context) {
    final conteudo = Material(
      color: CoresSonoLeve.superficie,
      borderRadius: BorderRadius.circular(raio),
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(raio),
        child: Padding(padding: padding, child: child),
      ),
    );
    if (aoTocar == null) return conteudo;
    return Semantics(button: true, label: rotuloSemantico, child: conteudo);
  }
}

/// Atalho da Home — "Meu ritual ↗", "Respirar ↗".
class CartaoAtalho extends StatelessWidget {
  const CartaoAtalho({
    super.key,
    required this.icone,
    required this.texto,
    required this.aoTocar,
  });

  final IconData icone;
  final String texto;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Cartao(
      aoTocar: aoTocar,
      rotuloSemantico: texto,
      raio: Dimensoes.raioGrande,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
      child: Row(
        children: [
          Icon(icone, size: 22, color: CoresSonoLeve.textoSecundario),
          const SizedBox(width: Dimensoes.espacoM),
          Expanded(child: Text(texto, style: TipografiaSonoLeve.corpoForte)),
          const Icon(Icons.north_east,
              size: 16, color: CoresSonoLeve.textoSecundario),
        ],
      ),
    );
  }
}

/// Item navegável com ícone circular — sons e técnicas de respiração.
class CartaoNavegavel extends StatelessWidget {
  const CartaoNavegavel({
    super.key,
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.aoTocar,
    this.indicador,
    this.comCirculo = true,
  });

  final IconData icone;
  final String titulo;
  final String descricao;
  final VoidCallback? aoTocar;

  /// Substitui a seta à direita (ex.: ícone de download).
  final Widget? indicador;
  final bool comCirculo;

  @override
  Widget build(BuildContext context) {
    final iconeWidget = Icon(icone, size: 24, color: CoresSonoLeve.lavanda);
    return Cartao(
      aoTocar: aoTocar,
      rotuloSemantico: '$titulo. $descricao',
      raio: Dimensoes.raioGrande,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          if (comCirculo)
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CoresSonoLeve.borda),
              ),
              child: iconeWidget,
            )
          else
            SizedBox(width: 40, child: iconeWidget),
          const SizedBox(width: Dimensoes.espacoG),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: TipografiaSonoLeve.tituloCartao),
                const SizedBox(height: 6),
                Text(descricao, style: TipografiaSonoLeve.legenda),
              ],
            ),
          ),
          const SizedBox(width: Dimensoes.espacoP),
          indicador ??
              const Icon(Icons.chevron_right,
                  size: 22, color: CoresSonoLeve.textoSecundario),
        ],
      ),
    );
  }
}

/// Cartão de dica/aviso gentil — "Um pequeno cuidado já é um começo."
class CartaoDica extends StatelessWidget {
  const CartaoDica({super.key, required this.titulo, required this.texto});

  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Cartao(
      raio: Dimensoes.raioGrande,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_outlined,
              size: 20, color: CoresSonoLeve.destaque),
          const SizedBox(width: Dimensoes.espacoM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TipografiaSonoLeve.legenda.copyWith(
                    color: CoresSonoLeve.destaque,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(texto, style: TipografiaSonoLeve.legenda),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
