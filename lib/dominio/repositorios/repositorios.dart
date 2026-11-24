/// Contratos (interfaces) da camada de dados.
///
/// As telas usam estes contratos. A versão de teste usa Firebase para sessão
/// e diário, e o próprio dispositivo para checklist, catálogo e preferências.
library;

import '../modelos/checklist_diario.dart';
import '../modelos/conteudo.dart';
import '../modelos/preferencias_usuario.dart';
import '../modelos/registro_sono.dart';
import '../modelos/usuario.dart';

/// Firebase Authentication (e-mail e senha).
abstract interface class AuthRepository {
  /// Sessão existente, ou `null`.
  Future<Usuario?> usuarioAtual();

  /// Lança `FalhaAutenticacaoException` ou `FalhaConexaoException`.
  Future<Usuario> entrar({required String email, required String senha});

  Future<Usuario> cadastrar({
    required String nome,
    required String email,
    required String senha,
  });

  Future<void> sair();

  /// Remove a conta de autenticação (RNF09).
  Future<void> excluirConta(String uid);
}

/// Diário do sono — `usuarios/{uid}/registrosSono` (RF06–RF10).
abstract interface class RegistroSonoRepository {
  /// Do mais recente para o mais antigo.
  Future<List<RegistroSono>> listar(String uid);

  /// Valida RN01–RN04 e RN03 (um registro por dia). Retorna o registro com id.
  Future<RegistroSono> criar(String uid, RegistroSono registro);

  Future<RegistroSono> atualizar(String uid, RegistroSono registro);

  Future<void> excluir(String uid, String idRegistro);

  /// Exclusão de todos os dados do usuário (RN06 / RNF09).
  Future<void> excluirTodos(String uid);
}

/// Catálogo global — Firestore (`conteudo_*`, `config/catalogo`) + Storage,
/// sempre servido a partir do cache local (RN08, RN09).
abstract interface class ConteudoRepository {
  /// Catálogo em cache; no primeiro uso, o conteúdo embarcado no app.
  Future<CatalogoConteudo> carregarDoCache();

  /// Compara `config/catalogo.versao` com a versão local e baixa as novidades.
  /// Retorna `true` se o catálogo mudou. Lança `FalhaConexaoException` offline.
  Future<bool> sincronizar();

  /// Baixa o áudio do Storage para o aparelho e devolve o som atualizado.
  Future<Som> baixarAudio(Som som);
}

/// Progresso do checklist — somente no dispositivo (`shared_preferences`, RN07).
abstract interface class ChecklistRepository {
  Future<ChecklistDiario> carregar(DateTime dia);

  Future<void> salvar(ChecklistDiario checklist);

  /// Apaga todo o progresso local (exclusão de dados).
  Future<void> limpar();
}

/// Configurações da interface, vinculadas ao usuário.
abstract interface class PreferenciasRepository {
  Future<PreferenciasUsuario> carregar(String uid);

  Future<void> salvar(String uid, PreferenciasUsuario preferencias);

  Future<void> excluir(String uid);
}
