/// Implementações em memória dos repositórios — usadas pelo protótipo de
/// baixa fidelidade e pelos testes. Simulam latência de rede e falta de
/// conexão para que todos os estados das telas (carregando, erro, offline)
/// possam ser vistos e testados.
library;

import '../../core/utils/datas.dart';
import '../../dominio/erros.dart';
import '../../dominio/modelos/checklist_diario.dart';
import '../../dominio/modelos/conteudo.dart';
import '../../dominio/modelos/preferencias_usuario.dart';
import '../../dominio/modelos/registro_sono.dart';
import '../../dominio/modelos/usuario.dart';
import '../../dominio/repositorios/repositorios.dart';
import '../../dominio/servicos/conectividade.dart';
import 'dados_mock.dart';

Future<void> _aguardar(Duration latencia) => latencia == Duration.zero
    ? Future<void>.value()
    : Future<void>.delayed(latencia);

// =============================================================================
// Autenticação
// =============================================================================

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(
      {required this.conectividade, this.latencia = Duration.zero}) {
    _contas[DadosMock.emailDemo] = (
      senha: DadosMock.senhaDemo,
      usuario: Usuario(
        uid: DadosMock.uidDemo,
        nome: DadosMock.nomeDemo,
        email: DadosMock.emailDemo,
        criadoEm: DateTime(2026, 9, 1),
      ),
    );
  }

  final Conectividade conectividade;
  final Duration latencia;

  final Map<String, ({String senha, Usuario usuario})> _contas = {};
  Usuario? _sessao;
  int _proximoId = 1;

  static final RegExp _formatoEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  void _validarCredenciais(String email, String senha) {
    if (!_formatoEmail.hasMatch(email)) {
      throw const FalhaAutenticacaoException('Confira o e-mail digitado.');
    }
    if (senha.length < 6) {
      throw const FalhaAutenticacaoException(
          'A senha precisa ter pelo menos 6 caracteres.');
    }
  }

  @override
  Future<Usuario?> usuarioAtual() async {
    await _aguardar(latencia);
    return _sessao;
  }

  @override
  Future<Usuario> entrar({required String email, required String senha}) async {
    await _aguardar(latencia);
    final emailNormalizado = email.trim().toLowerCase();
    _validarCredenciais(emailNormalizado, senha);
    if (!conectividade.online) {
      throw const FalhaConexaoException(
          'Sem conexão. Para entrar, conecte-se à internet.');
    }
    final conta = _contas[emailNormalizado];
    if (conta == null || conta.senha != senha) {
      throw const FalhaAutenticacaoException('E-mail ou senha incorretos.');
    }
    return _sessao = conta.usuario;
  }

  @override
  Future<Usuario> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    await _aguardar(latencia);
    final emailNormalizado = email.trim().toLowerCase();
    if (nome.trim().isEmpty) {
      throw const FalhaAutenticacaoException('Conte como podemos te chamar.');
    }
    _validarCredenciais(emailNormalizado, senha);
    if (!conectividade.online) {
      throw const FalhaConexaoException(
          'Sem conexão. Para criar a conta, conecte-se à internet.');
    }
    if (_contas.containsKey(emailNormalizado)) {
      throw const FalhaAutenticacaoException(
          'Já existe uma conta com este e-mail.');
    }
    final usuario = Usuario(
      uid: 'uid-mock-${_proximoId++}',
      nome: nome.trim(),
      email: emailNormalizado,
      criadoEm: DateTime.now(),
    );
    _contas[emailNormalizado] = (senha: senha, usuario: usuario);
    return _sessao = usuario;
  }

  @override
  Future<void> sair() async {
    await _aguardar(latencia);
    _sessao = null;
  }

  @override
  Future<void> excluirConta(String uid) async {
    await _aguardar(latencia);
    if (!conectividade.online) throw const FalhaConexaoException();
    _contas.removeWhere((_, conta) => conta.usuario.uid == uid);
    if (_sessao?.uid == uid) _sessao = null;
  }
}

// =============================================================================
// Diário do sono
// =============================================================================

/// Como o Firestore com persistência offline: grava mesmo sem internet.
class MockRegistroSonoRepository implements RegistroSonoRepository {
  MockRegistroSonoRepository({this.latencia = Duration.zero, DateTime? hoje}) {
    _porUsuario[DadosMock.uidDemo] =
        DadosMock.registrosDemo(hoje ?? DateTime.now());
  }

  final Duration latencia;
  final Map<String, List<RegistroSono>> _porUsuario = {};
  int _proximoId = 1;

  List<RegistroSono> _de(String uid) => _porUsuario.putIfAbsent(uid, () => []);

  void _validar(String uid, RegistroSono registro) {
    final problemas = registro.validar(); // RN01, RN02, RN04
    if (problemas.isNotEmpty) throw RegraNegocioException(problemas.first);

    final outraNoMesmoDia = _de(uid).any(
      (r) => r.id != registro.id && Datas.mesmoDia(r.data, registro.data),
    );
    if (outraNoMesmoDia) {
      // RN03
      throw const RegraNegocioException(
        'Você já registrou esta noite. Abra o registro existente para editá-lo.',
      );
    }
  }

  @override
  Future<List<RegistroSono>> listar(String uid) async {
    await _aguardar(latencia);
    return List<RegistroSono>.of(_de(uid))
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  @override
  Future<RegistroSono> criar(String uid, RegistroSono registro) async {
    await _aguardar(latencia);
    _validar(uid, registro);
    final salvo = registro.copyWith(id: 'reg-${_proximoId++}');
    _de(uid).add(salvo);
    return salvo;
  }

  @override
  Future<RegistroSono> atualizar(String uid, RegistroSono registro) async {
    await _aguardar(latencia);
    final lista = _de(uid);
    final indice = lista.indexWhere((r) => r.id == registro.id);
    if (indice < 0) {
      throw const RegraNegocioException('Este registro não existe mais.');
    }
    _validar(uid, registro);
    final atualizado = registro.copyWith(atualizadoEm: DateTime.now());
    lista[indice] = atualizado;
    return atualizado;
  }

  @override
  Future<void> excluir(String uid, String idRegistro) async {
    await _aguardar(latencia);
    _de(uid).removeWhere((r) => r.id == idRegistro);
  }

  @override
  Future<void> excluirTodos(String uid) async {
    await _aguardar(latencia);
    _porUsuario.remove(uid);
  }
}

// =============================================================================
// Catálogo de conteúdo
// =============================================================================

class MockConteudoRepository implements ConteudoRepository {
  MockConteudoRepository(
      {required this.conectividade, this.latencia = Duration.zero})
      : _cache = DadosMock.catalogoEmbarcado;

  final Conectividade conectividade;
  final Duration latencia;

  /// O que o aparelho tem guardado (começa com o conteúdo embarcado).
  CatalogoConteudo _cache;

  /// O que está publicado "no Firebase".
  final CatalogoConteudo _remoto = DadosMock.catalogoRemoto;

  @override
  Future<CatalogoConteudo> carregarDoCache() async {
    await _aguardar(latencia);
    return _cache;
  }

  @override
  Future<bool> sincronizar() async {
    await _aguardar(latencia);
    if (!conectividade.online) throw const FalhaConexaoException();

    // RN09: só baixa quando a versão publicada é maior que a local.
    final versaoRemota =
        VersaoCatalogo(versao: _remoto.versao, atualizadoEm: DateTime.now());
    if (!versaoRemota.precisaSincronizar(_cache.versao)) return false;

    // Mantém os áudios que já estão no aparelho, se não mudaram.
    final locais = {for (final s in _cache.sons) s.id: s};
    final sons = [
      for (final s in _remoto.sons)
        s.comCaminhoLocal(
          locais[s.id] != null &&
                  !s.atualizadoEm.isAfter(locais[s.id]!.atualizadoEm)
              ? locais[s.id]!.caminhoLocal
              : null,
        ),
    ];
    _cache = CatalogoConteudo(
      versao: _remoto.versao,
      sons: sons,
      dicas: _remoto.dicas,
      habitos: _remoto.habitos,
      respiracoes: _remoto.respiracoes,
    );
    return true;
  }

  @override
  Future<Som> baixarAudio(Som som) async {
    if (!conectividade.online) throw const FalhaConexaoException();
    await _aguardar(latencia * 3); // downloads demoram mais
    final baixado =
        som.comCaminhoLocal('mock://dispositivo/audios/${som.id}.mp3');
    _cache = _cache.copyWith(
      sons: [for (final s in _cache.sons) s.id == som.id ? baixado : s],
    );
    return baixado;
  }
}

// =============================================================================
// Checklist (local) e preferências
// =============================================================================

/// No produto final: `shared_preferences`, chave "checklist_YYYY-MM-DD".
class MockChecklistRepository implements ChecklistRepository {
  final Map<String, Set<String>> _armazenamento = {};

  @override
  Future<ChecklistDiario> carregar(DateTime dia) async => ChecklistDiario(
      data: dia,
      idsConcluidos: _armazenamento[Datas.chaveDia(dia)] ?? const <String>{});

  @override
  Future<void> salvar(ChecklistDiario checklist) async {
    _armazenamento[Datas.chaveDia(checklist.data)] =
        Set<String>.of(checklist.idsConcluidos);
  }

  @override
  Future<void> limpar() async => _armazenamento.clear();
}

class MockPreferenciasRepository implements PreferenciasRepository {
  final Map<String, PreferenciasUsuario> _porUsuario = {};

  @override
  Future<PreferenciasUsuario> carregar(String uid) async =>
      _porUsuario[uid] ?? const PreferenciasUsuario();

  @override
  Future<void> salvar(String uid, PreferenciasUsuario preferencias) async {
    _porUsuario[uid] = preferencias;
  }

  @override
  Future<void> excluir(String uid) async {
    _porUsuario.remove(uid);
  }
}
