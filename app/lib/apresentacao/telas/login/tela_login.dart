import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/tema/dimensoes.dart';
import '../../../core/tema/tipografia.dart';
import '../../../dados/mock/dados_mock.dart';
import '../../../estado/auth_controller.dart';
import '../../componentes/componentes.dart';

/// Login e cadastro por e-mail e senha (Firebase Auth).
///
/// Não há tela de login nos protótipos do Figma: esta segue os mesmos
/// componentes e o mesmo tom das demais.
class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  // Protótipo: credenciais de demonstração já preenchidas.
  final _nome = TextEditingController();
  final _email = TextEditingController(text: DadosMock.emailDemo);
  final _senha = TextEditingController(text: DadosMock.senhaDemo);

  bool _criandoConta = false;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  void _alternarModo() {
    context.read<AuthController>().limparErro();
    setState(() {
      _criandoConta = !_criandoConta;
      if (_criandoConta) {
        _email.clear();
        _senha.clear();
      }
    });
  }

  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthController>();
    if (_criandoConta) {
      await auth.cadastrar(
          nome: _nome.text, email: _email.text, senha: _senha.text);
    } else {
      await auth.entrar(email: _email.text, senha: _senha.text);
    }
    // Em caso de sucesso, o PortaoAutenticacao troca para o app sozinho.
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: Dimensoes.paddingTela,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Dimensoes.espacoXg),
                const Text('sonoleve', style: TipografiaSonoLeve.marca),
                const SizedBox(height: Dimensoes.espacoXg),
                const Center(
                  child: AneisConcentricos(
                    largura: 210,
                    altura: 148,
                    child: IconeAneis(Icons.bedtime_outlined),
                  ),
                ),
                const SizedBox(height: Dimensoes.espacoXg),
                TituloTela(
                  _criandoConta
                      ? 'Um lugar\npara descansar.'
                      : 'Boa noite.\nVamos desacelerar?',
                  subtitulo: _criandoConta
                      ? 'Crie sua conta para guardar o seu diário do sono.'
                      : 'Entre para acompanhar o seu descanso.',
                ),
                const SizedBox(height: Dimensoes.espacoXg),
                if (_criandoConta) ...[
                  CampoTexto(
                    rotulo: 'Como podemos te chamar?',
                    controlador: _nome,
                    dica: 'Seu nome',
                    acaoTeclado: TextInputAction.next,
                    autofill: const [AutofillHints.name],
                  ),
                  const SizedBox(height: Dimensoes.espacoG),
                ],
                CampoTexto(
                  rotulo: 'E-mail',
                  controlador: _email,
                  dica: 'voce@email.com',
                  teclado: TextInputType.emailAddress,
                  acaoTeclado: TextInputAction.next,
                  autofill: const [AutofillHints.email],
                ),
                const SizedBox(height: Dimensoes.espacoG),
                CampoTexto(
                  rotulo: 'Senha',
                  controlador: _senha,
                  dica: 'Pelo menos 6 caracteres',
                  ocultar: true,
                  acaoTeclado: TextInputAction.done,
                  aoEnviar: (_) => _enviar(),
                  autofill: [
                    _criandoConta
                        ? AutofillHints.newPassword
                        : AutofillHints.password
                  ],
                ),
                if (auth.erro != null) ...[
                  const SizedBox(height: Dimensoes.espacoG),
                  AvisoEmLinha(mensagem: auth.erro!),
                ],
                const SizedBox(height: Dimensoes.espacoXg),
                BotaoPrimario(
                  texto: _criandoConta ? 'Criar minha conta' : 'Entrar',
                  carregando: auth.processando,
                  aoTocar: _enviar,
                ),
                const SizedBox(height: Dimensoes.espacoM),
                Center(
                  child: BotaoTexto(
                    texto: _criandoConta
                        ? 'Já tenho uma conta'
                        : 'Criar uma conta',
                    aoTocar: auth.processando ? null : _alternarModo,
                  ),
                ),
                if (!_criandoConta) ...[
                  const SizedBox(height: Dimensoes.espacoG),
                  const NotaRodape(
                    icone: Icons.info_outline,
                    texto:
                        'Protótipo: ${DadosMock.emailDemo} · senha ${DadosMock.senhaDemo}',
                  ),
                ],
                const SizedBox(height: Dimensoes.espacoXg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
