import 'package:flutter/material.dart';

import '../../core/tema/cores.dart';
import '../../core/tema/dimensoes.dart';
import '../../core/tema/tipografia.dart';

/// Campo de texto no estilo do SonoLeve (rótulo acima, superfície escura).
class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.rotulo,
    required this.controlador,
    this.dica,
    this.erro,
    this.ocultar = false,
    this.teclado,
    this.acaoTeclado,
    this.aoEnviar,
    this.autofill,
    this.maxLinhas = 1,
    this.maxCaracteres,
  });

  final String rotulo;
  final TextEditingController controlador;
  final String? dica;
  final String? erro;
  final bool ocultar;
  final TextInputType? teclado;
  final TextInputAction? acaoTeclado;
  final ValueChanged<String>? aoEnviar;
  final Iterable<String>? autofill;
  final int maxLinhas;
  final int? maxCaracteres;

  @override
  Widget build(BuildContext context) {
    final bordaBase = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Dimensoes.raioCartao),
      borderSide: BorderSide.none,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo,
            style: TipografiaSonoLeve.subtitulo.copyWith(fontSize: 13)),
        const SizedBox(height: Dimensoes.espacoP),
        TextField(
          controller: controlador,
          obscureText: ocultar,
          keyboardType: teclado,
          textInputAction: acaoTeclado,
          onSubmitted: aoEnviar,
          autofillHints: autofill,
          maxLines: ocultar ? 1 : maxLinhas,
          maxLength: maxCaracteres,
          style: TipografiaSonoLeve.corpoForte,
          cursorColor: CoresSonoLeve.lavanda,
          decoration: InputDecoration(
            hintText: dica,
            hintStyle: TipografiaSonoLeve.corpo,
            errorText: erro,
            errorStyle: TipografiaSonoLeve.legenda
                .copyWith(color: CoresSonoLeve.destaque),
            counterStyle: TipografiaSonoLeve.mini,
            filled: true,
            fillColor: CoresSonoLeve.superficie,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: bordaBase,
            enabledBorder: bordaBase,
            focusedBorder: bordaBase.copyWith(
              borderSide: const BorderSide(color: CoresSonoLeve.lavandaSuave),
            ),
            errorBorder: bordaBase.copyWith(
              borderSide: const BorderSide(color: CoresSonoLeve.destaque),
            ),
            focusedErrorBorder: bordaBase.copyWith(
              borderSide: const BorderSide(color: CoresSonoLeve.destaque),
            ),
          ),
        ),
      ],
    );
  }
}
