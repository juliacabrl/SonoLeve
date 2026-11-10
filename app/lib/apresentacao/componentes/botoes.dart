import 'package:flutter/material.dart';

import '../../core/tema/cores.dart';
import '../../core/tema/dimensoes.dart';
import '../../core/tema/tipografia.dart';

/// Botão principal de largura total — "Começar a relaxar", "Salvar minha noite".
class BotaoPrimario extends StatelessWidget {
  const BotaoPrimario({
    super.key,
    required this.texto,
    required this.aoTocar,
    this.icone,
    this.carregando = false,
  });

  final String texto;
  final VoidCallback? aoTocar;
  final IconData? icone;
  final bool carregando;

  static const Color _corInativa = Color(0x667C8DB5);

  @override
  Widget build(BuildContext context) {
    final habilitado = aoTocar != null && !carregando;
    return Semantics(
      button: true,
      enabled: habilitado,
      label: texto,
      excludeSemantics: true,
      child: SizedBox(
        width: double.infinity,
        height: Dimensoes.alturaBotao,
        child: Material(
          color: aoTocar == null ? _corInativa : CoresSonoLeve.primaria,
          borderRadius: BorderRadius.circular(Dimensoes.raioBotao),
          child: InkWell(
            onTap: habilitado ? aoTocar : null,
            borderRadius: BorderRadius.circular(Dimensoes.raioBotao),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Dimensoes.espacoG),
              child: Center(
                child: carregando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: CoresSonoLeve.textoSobrePrimaria,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icone != null) ...[
                            Icon(icone,
                                size: 20,
                                color: CoresSonoLeve.textoSobrePrimaria),
                            const SizedBox(width: Dimensoes.espacoP),
                          ],
                          // Flexible: com fonte grande (acessibilidade) o texto
                          // quebra em até 2 linhas em vez de estourar o botão.
                          Flexible(
                            child: Text(
                              texto,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TipografiaSonoLeve.botao.copyWith(
                                  color: CoresSonoLeve.textoSobrePrimaria),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão em pílula com contorno — "Desligar em 30 min".
class BotaoContorno extends StatelessWidget {
  const BotaoContorno({
    super.key,
    required this.texto,
    required this.aoTocar,
    this.icone,
  });

  final String texto;
  final VoidCallback? aoTocar;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: texto,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensoes.raioPilula),
          side: const BorderSide(color: CoresSonoLeve.borda),
        ),
        child: InkWell(
          onTap: aoTocar,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensoes.raioPilula),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icone != null) ...[
                  Icon(icone, size: 16, color: CoresSonoLeve.textoSecundario),
                  const SizedBox(width: Dimensoes.espacoP),
                ],
                Flexible(
                  child: Text(
                    texto,
                    overflow: TextOverflow.ellipsis,
                    style: TipografiaSonoLeve.legenda
                        .copyWith(color: CoresSonoLeve.texto),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Link discreto — "Ver histórico", "Criar conta".
class BotaoTexto extends StatelessWidget {
  const BotaoTexto({
    super.key,
    required this.texto,
    required this.aoTocar,
    this.cor = CoresSonoLeve.lavanda,
  });

  final String texto;
  final VoidCallback? aoTocar;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: texto,
      excludeSemantics: true,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(Dimensoes.raioPequeno),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(
            texto,
            style: TipografiaSonoLeve.legenda
                .copyWith(color: cor, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

/// Botão circular de ícone — controles do player e do contador.
class BotaoCircular extends StatelessWidget {
  const BotaoCircular({
    super.key,
    required this.icone,
    required this.aoTocar,
    required this.rotulo,
    this.tamanho = 44,
    this.corFundo = CoresSonoLeve.fundo,
    this.corIcone = CoresSonoLeve.texto,
    this.tamanhoIcone = 22,
  });

  final IconData icone;
  final VoidCallback? aoTocar;
  final String rotulo;
  final double tamanho;
  final Color corFundo;
  final Color corIcone;
  final double tamanhoIcone;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: rotulo,
      excludeSemantics: true,
      child: Material(
        color: corFundo,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: aoTocar,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: tamanho,
            height: tamanho,
            child: Icon(
              icone,
              size: tamanhoIcone,
              color: aoTocar == null ? CoresSonoLeve.borda : corIcone,
            ),
          ),
        ),
      ),
    );
  }
}
