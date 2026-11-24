import 'package:flutter/foundation.dart';

import '../dominio/erros.dart';
import '../dominio/modelos/usuario.dart';
import '../injecao/dependencias.dart';
import 'notificador_seguro.dart';

enum EstadoSessao { verificando, deslogado, logado }

/// Sessão do usuário (Firebase Auth) e exclusão de dados (RNF09).
class AuthController extends ChangeNotifier with NotificadorSeguro {
  AuthController(this._dependencias);

  final Dependencias _dependencias;

  EstadoSessao _estado = EstadoSessao.verificando;
  Usuario? _usuario;
  bool _processando = false;
  String? _erro;

  EstadoSessao get estado => _estado;
  Usuario? get usuario => _usuario;
  bool get processando => _processando;

  /// Mensagem da última falha (credenciais, conexão), pronta para exibir.
  String? get erro => _erro;

  Future<void> iniciar() async {
    try {
      _usuario = await _dependencias.auth.usuarioAtual();
    } on FalhaSonoLeve {
      _usuario = null;
    }
    _estado = _usuario == null ? EstadoSessao.deslogado : EstadoSessao.logado;
    notifyListeners();
  }

  Future<bool> entrar({required String email, required String senha}) =>
      _executar(() => _dependencias.auth.entrar(email: email, senha: senha));

  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) =>
      _executar(() =>
          _dependencias.auth.cadastrar(nome: nome, email: email, senha: senha));

  Future<bool> _executar(Future<Usuario> Function() acao) async {
    _processando = true;
    _erro = null;
    notifyListeners();
    try {
      _usuario = await acao();
      _estado = EstadoSessao.logado;
      return true;
    } on FalhaSonoLeve catch (falha) {
      _erro = falha.mensagem;
      return false;
    } finally {
      _processando = false;
      notifyListeners();
    }
  }

  void limparErro() {
    if (_erro == null) return;
    _erro = null;
    notifyListeners();
  }

  Future<void> sair() async {
    await _dependencias.auth.sair();
    _usuario = null;
    _estado = EstadoSessao.deslogado;
    notifyListeners();
  }

  /// Apaga registros, preferências, progresso local e a conta (RN06 / RNF09).
  /// Retorna a mensagem de erro, ou `null` em caso de sucesso.
  Future<String?> excluirMeusDados() async {
    final uid = _usuario?.uid;
    if (uid == null) return null;
    if (!_dependencias.conectividade.online) {
      return const FalhaConexaoException(
        'Para excluir seus dados, conecte-se à internet.',
      ).mensagem;
    }
    try {
      await _dependencias.registros.excluirTodos(uid);
      await _dependencias.preferencias.excluir(uid);
      await _dependencias.checklist.limpar();
      await _dependencias.auth.excluirConta(uid);
    } on FalhaSonoLeve catch (falha) {
      return falha.mensagem;
    }
    _usuario = null;
    _estado = EstadoSessao.deslogado;
    notifyListeners();
    return null;
  }
}
