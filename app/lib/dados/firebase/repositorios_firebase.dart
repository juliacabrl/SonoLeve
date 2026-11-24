import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/utils/datas.dart';
import '../../dominio/erros.dart';
import '../../dominio/modelos/registro_sono.dart';
import '../../dominio/modelos/usuario.dart';
import '../../dominio/repositorios/repositorios.dart';

class AuthFirebase implements AuthRepository {
  AuthFirebase(this._auth);

  final FirebaseAuth _auth;

  Usuario _converter(User user, {String? nome}) {
    final email = user.email ?? '';
    return Usuario(
      uid: user.uid,
      nome: nome ?? user.displayName ?? email.split('@').first,
      email: email,
      criadoEm: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  void _validarCredenciais(String email, String senha) {
    if (!email.trim().contains('@')) {
      throw const FalhaAutenticacaoException('Confira o e-mail digitado.');
    }
    if (senha.length < 6) {
      throw const FalhaAutenticacaoException(
        'Use uma senha com pelo menos 6 caracteres.',
      );
    }
  }

  @override
  Future<Usuario?> usuarioAtual() async {
    final user = await _auth.authStateChanges().first;
    return user == null ? null : _converter(user);
  }

  @override
  Future<Usuario> entrar({required String email, required String senha}) async {
    _validarCredenciais(email, senha);
    try {
      final credencial = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      return _converter(credencial.user!);
    } on FirebaseAuthException catch (erro) {
      throw _traduzir(erro);
    }
  }

  @override
  Future<Usuario> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    if (nome.trim().isEmpty) {
      throw const FalhaAutenticacaoException('Informe seu nome.');
    }
    _validarCredenciais(email, senha);

    try {
      final credencial = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      final user = credencial.user!;
      // Se a atualização do nome falhar, a conta já existe e pode ser usada.
      try {
        await user.updateDisplayName(nome.trim());
      } on FirebaseAuthException {
        return _converter(user);
      }
      return _converter(user, nome: nome.trim());
    } on FirebaseAuthException catch (erro) {
      throw _traduzir(erro);
    }
  }

  @override
  Future<void> sair() => _auth.signOut();

  @override
  Future<void> excluirConta(String uid) async {
    final user = _auth.currentUser;
    if (user == null || user.uid != uid) return;
    try {
      await user.delete();
    } on FirebaseAuthException catch (erro) {
      throw _traduzir(erro);
    }
  }

  FalhaSonoLeve _traduzir(FirebaseAuthException erro) => switch (erro.code) {
    'network-request-failed' => const FalhaConexaoException(),
    'invalid-email' => const FalhaAutenticacaoException(
      'Confira o e-mail digitado.',
    ),
    'weak-password' => const FalhaAutenticacaoException(
      'Use uma senha com pelo menos 6 caracteres.',
    ),
    'email-already-in-use' => const FalhaAutenticacaoException(
      'Já existe uma conta com este e-mail.',
    ),
    'invalid-credential' || 'wrong-password' || 'user-not-found' =>
      const FalhaAutenticacaoException('E-mail ou senha incorretos.'),
    'requires-recent-login' => const FalhaAutenticacaoException(
      'Entre novamente para excluir sua conta.',
    ),
    _ => const FalhaAutenticacaoException(
      'Não foi possível acessar a conta. Tente novamente.',
    ),
  };
}

class DiarioFirestore implements RegistroSonoRepository {
  DiarioFirestore(this._banco);

  final FirebaseFirestore _banco;

  CollectionReference<RegistroSono> _registros(String uid) => _banco
      .collection('usuarios')
      .doc(uid)
      .collection('registrosSono')
      .withConverter<RegistroSono>(
        fromFirestore: (documento, _) =>
            RegistroSono.fromMap(documento.id, documento.data()!),
        toFirestore: (registro, _) => {
          ...registro.toMap(),
          // Data de calendário, sem mudança de dia por causa do fuso.
          'data': Datas.chaveDia(registro.data),
        },
      );

  Future<T> _operar<T>(Future<T> Function() acao) async {
    try {
      return await acao();
    } on FirebaseException catch (erro) {
      if (erro.code == 'unavailable' || erro.code == 'deadline-exceeded') {
        throw const FalhaConexaoException();
      }
      if (erro.code == 'permission-denied') {
        throw const RegraNegocioException(
          'O banco recusou a operação. Confira a sessão e as regras do Firestore.',
        );
      }
      throw const RegraNegocioException(
        'Não foi possível acessar o diário. Tente novamente.',
      );
    }
  }

  void _validar(RegistroSono registro) {
    final problemas = registro.validar();
    if (problemas.isNotEmpty) throw RegraNegocioException(problemas.first);
  }

  @override
  Future<List<RegistroSono>> listar(String uid) => _operar(() async {
    final consulta = await _registros(
      uid,
    ).orderBy('data', descending: true).get();
    return consulta.docs.map((documento) => documento.data()).toList();
  });

  @override
  Future<RegistroSono> criar(String uid, RegistroSono registro) async {
    _validar(registro);
    final dia = Datas.chaveDia(registro.data);
    final documento = _registros(uid).doc(dia);
    final novo = registro.copyWith(id: dia);

    return _operar(
      () => _banco.runTransaction((transacao) async {
        if ((await transacao.get(documento)).exists) {
          throw const RegraNegocioException(
            'Já existe um registro para esse dia.',
          );
        }
        transacao.set(documento, novo);
        return novo;
      }),
    );
  }

  @override
  Future<RegistroSono> atualizar(String uid, RegistroSono registro) async {
    _validar(registro);
    final dia = Datas.chaveDia(registro.data);
    final origem = _registros(uid).doc(registro.id);
    final destino = _registros(uid).doc(dia);

    return _operar(
      () => _banco.runTransaction((transacao) async {
        final atual = (await transacao.get(origem)).data();
        if (atual == null) {
          throw const RegraNegocioException('Este registro não existe mais.');
        }
        // Se a data mudar, a cópia e a exclusão acontecem juntas.
        if (origem.id != destino.id && (await transacao.get(destino)).exists) {
          throw const RegraNegocioException(
            'Já existe um registro para esse dia.',
          );
        }
        final atualizado = atual.copyWith(
          id: dia,
          data: registro.data,
          horasDormidas: registro.horasDormidas,
          qualidade: registro.qualidade,
          observacao: registro.observacao,
          atualizadoEm: DateTime.now(),
        );
        transacao.set(destino, atualizado);
        if (origem.id != destino.id) transacao.delete(origem);
        return atualizado;
      }),
    );
  }

  @override
  Future<void> excluir(String uid, String idRegistro) => _operar(
    () => _banco.runTransaction((transacao) async {
      final documento = _registros(uid).doc(idRegistro);
      await transacao.get(documento);
      transacao.delete(documento);
    }),
  );

  @override
  Future<void> excluirTodos(String uid) => _operar(() async {
    final consulta = await _registros(
      uid,
    ).limit(250).get(const GetOptions(source: Source.server));
    if (consulta.docs.isEmpty) return;
    final lote = _banco.batch();
    for (final registro in consulta.docs) {
      lote.delete(registro.reference);
    }
    await lote.commit();
    if (consulta.docs.length == 250) await excluirTodos(uid);
  });
}
