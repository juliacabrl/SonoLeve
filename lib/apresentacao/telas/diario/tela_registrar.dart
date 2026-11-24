import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/rotas/rotas.dart';
import '../../../core/tema/cores.dart';
import '../../../core/tema/dimensoes.dart';
import '../../../core/tema/tipografia.dart';
import '../../../core/utils/datas.dart';
import '../../../core/utils/formatadores.dart';
import '../../../dominio/modelos/registro_sono.dart';
import '../../../estado/registro_sono_controller.dart';
import '../../componentes/componentes.dart';

/// Registrar ou editar uma noite — `prototype/figma/07-registrar.svg`.
/// Cobre C, U e D do CRUD (RF06, RF07, RF09, RF10).
class TelaRegistrar extends StatefulWidget {
  const TelaRegistrar({super.key, this.registro});

  /// `null` = nova noite; preenchido = edição.
  final RegistroSono? registro;

  @override
  State<TelaRegistrar> createState() => _TelaRegistrarState();
}

class _TelaRegistrarState extends State<TelaRegistrar> {
  late DateTime _data;
  late int _minutos;
  late int _qualidade;
  late final TextEditingController _observacao;
  bool _salvando = false;
  String? _erro;

  bool get _editando => widget.registro != null;

  @override
  void initState() {
    super.initState();
    final r = widget.registro;
    _data = r?.data ?? Datas.soDia(DateTime.now());
    _minutos = r?.minutosDormidos ?? 7 * 60;
    _qualidade = r?.qualidade ?? 4;
    _observacao = TextEditingController(text: r?.observacao ?? '');
  }

  @override
  void dispose() {
    _observacao.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final hoje = Datas.soDia(DateTime.now());
    final umAnoAtras = DateTime(hoje.year - 1, hoje.month, hoje.day);
    // A data inicial precisa estar dentro do intervalo (registros antigos).
    final primeira = _data.isBefore(umAnoAtras) ? _data : umAnoAtras;
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data.isAfter(hoje) ? hoje : _data,
      firstDate: primeira,
      lastDate: hoje,
      helpText: 'Noite encerrada em',
      cancelText: 'Cancelar',
      confirmText: 'Escolher',
    );
    if (escolhida != null && mounted) {
      setState(() {
        _data = Datas.soDia(escolhida);
        _erro = null;
      });
    }
  }

  Future<void> _salvar() async {
    FocusScope.of(context).unfocus();
    final controller = context.read<RegistroSonoController>();
    final base = widget.registro;
    final registro = base == null
        ? RegistroSono.novo(
            data: _data,
            horasDormidas: _minutos / 60,
            qualidade: _qualidade,
            observacao: _observacao.text.trim(),
          )
        : base.copyWith(
            data: _data,
            horasDormidas: _minutos / 60,
            qualidade: _qualidade,
            observacao: _observacao.text.trim(),
          );

    setState(() {
      _salvando = true;
      _erro = null;
    });
    final erro = await controller.salvar(registro);
    if (!mounted) return;
    if (erro != null) {
      setState(() {
        _salvando = false;
        _erro = erro;
      });
      return;
    }
    Dialogos.mensagem(context,
        _editando ? 'Registro atualizado.' : 'Noite registrada. Bom descanso.');
    Navigator.of(context).pop();
  }

  Future<void> _excluir() async {
    final registro = widget.registro;
    if (registro == null) return;
    final controller = context.read<RegistroSonoController>();
    final confirmado = await Dialogos.confirmar(
      context,
      titulo: 'Excluir esta noite?',
      mensagem:
          'O registro de ${Formatadores.dataExtensa(registro.data)} será apagado.',
      textoConfirmar: 'Excluir',
    );
    if (!confirmado || !mounted) return;
    final erro = await controller.excluir(registro.id);
    if (!mounted) return;
    if (erro != null) {
      setState(() => _erro = erro);
      return;
    }
    Dialogos.mensagem(context, 'Registro excluído.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RegistroSonoController>();
    // RN03: avisa antes de salvar se já existe outra noite neste dia.
    final conflito =
        controller.registroDoDia(_data, excetoId: widget.registro?.id);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Dimensoes.paddingTela,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CabecalhoVoltar(
                acao: _editando
                    ? IconButton(
                        tooltip: 'Excluir registro',
                        onPressed: _salvando ? null : _excluir,
                        icon: const Icon(Icons.delete_outline,
                            color: CoresSonoLeve.textoSecundario),
                      )
                    : null,
              ),
              const SizedBox(height: Dimensoes.espacoP),
              TituloTela(
                _editando ? 'Ajuste a\nsua noite.' : 'Como foi\na sua noite?',
                subtitulo: 'Não existe resposta certa. Só a sua percepção.',
              ),
              const SizedBox(height: Dimensoes.espacoXg),
              const _Rotulo('Noite encerrada em'),
              Cartao(
                aoTocar: _escolherData,
                rotuloSemantico:
                    'Alterar data: ${Formatadores.dataExtensa(_data)}',
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(Formatadores.dataExtensa(_data),
                          style: TipografiaSonoLeve.corpoForte),
                    ),
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: CoresSonoLeve.textoSecundario),
                    const SizedBox(width: 4),
                    const Icon(Icons.expand_more,
                        size: 20, color: CoresSonoLeve.textoSecundario),
                  ],
                ),
              ),
              if (conflito != null) ...[
                const SizedBox(height: Dimensoes.espacoM),
                const AvisoEmLinha(mensagem: 'Você já registrou esta noite.'),
                BotaoTexto(
                  texto: 'Abrir o registro desta noite',
                  aoTocar: () => Navigator.of(context).pushReplacementNamed(
                      Rotas.registrar,
                      arguments: conflito),
                ),
              ],
              const SizedBox(height: Dimensoes.espacoXg),
              const _Rotulo('Quanto tempo você dormiu?'),
              ContadorDuracao(
                minutos: _minutos,
                aoMudar: (valor) => setState(() => _minutos = valor),
              ),
              const SizedBox(height: Dimensoes.espacoXg),
              const _Rotulo('Como você avalia seu descanso?'),
              SeletorEstrelas(
                valor: _qualidade,
                rotulo: RegistroSono.rotulosQualidade[_qualidade] ?? '',
                aoMudar: (valor) => setState(() => _qualidade = valor),
              ),
              const SizedBox(height: Dimensoes.espacoXg),
              CampoTexto(
                rotulo: 'Quer anotar algo? (opcional)',
                controlador: _observacao,
                dica: 'Ex.: acordei uma vez durante a noite',
                maxLinhas: 3,
                maxCaracteres: RegistroSono.tamanhoMaximoObservacao,
              ),
              if (_erro != null) ...[
                const SizedBox(height: Dimensoes.espacoM),
                AvisoEmLinha(mensagem: _erro!),
              ],
              const SizedBox(height: Dimensoes.espacoXg),
              BotaoPrimario(
                texto: _editando ? 'Salvar alterações' : 'Salvar minha noite',
                carregando: _salvando,
                aoTocar: conflito == null ? _salvar : null,
              ),
              const SizedBox(height: Dimensoes.espacoM),
              const NotaRodape(
                icone: Icons.lock_outline,
                texto: 'Seus registros ficam protegidos na sua conta.',
              ),
              const SizedBox(height: Dimensoes.espacoXg),
            ],
          ),
        ),
      ),
    );
  }
}

class _Rotulo extends StatelessWidget {
  const _Rotulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: Dimensoes.espacoP),
        child: Text(texto,
            style: TipografiaSonoLeve.subtitulo.copyWith(fontSize: 13)),
      );
}
