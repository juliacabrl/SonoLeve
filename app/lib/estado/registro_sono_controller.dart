import 'package:flutter/foundation.dart';

import '../core/utils/datas.dart';
import '../dominio/erros.dart';
import '../dominio/modelos/registro_sono.dart';
import '../dominio/modelos/resumo_semanal.dart';
import '../dominio/repositorios/repositorios.dart';
import 'notificador_seguro.dart';

/// Diário do sono: CRUD de registros e resumo semanal (RF06–RF11).
class RegistroSonoController extends ChangeNotifier with NotificadorSeguro {
  RegistroSonoController(this._repositorio);

  final RegistroSonoRepository _repositorio;

  String? _uid;
  List<RegistroSono> _registros = const [];
  bool _carregando = false;
  String? _erroCarregamento;

  /// Do mais recente para o mais antigo.
  List<RegistroSono> get registros => _registros;
  bool get carregando => _carregando;
  String? get erroCarregamento => _erroCarregamento;

  ResumoSemanal resumo([DateTime? referencia]) =>
      ResumoSemanal.calcular(_registros, referencia ?? DateTime.now());

  /// Registro já existente para o dia, ignorando [excetoId] (RN03).
  RegistroSono? registroDoDia(DateTime dia, {String? excetoId}) {
    for (final r in _registros) {
      if (r.id != excetoId && Datas.mesmoDia(r.data, dia)) return r;
    }
    return null;
  }

  Future<void> carregar(String uid) async {
    if (_uid != uid) _registros = const [];
    _uid = uid;
    _carregando = true;
    _erroCarregamento = null;
    notifyListeners();
    try {
      _registros = await _repositorio.listar(uid);
    } on FalhaSonoLeve catch (falha) {
      _erroCarregamento = falha.mensagem;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// Cria ou atualiza. Retorna a mensagem de erro, ou `null` se deu certo.
  Future<String?> salvar(RegistroSono registro) async {
    final uid = _uid;
    if (uid == null) return 'Entre na sua conta para registrar suas noites.';
    final problemas = registro.validar();
    if (problemas.isNotEmpty) return problemas.first;
    try {
      if (registro.salvo) {
        await _repositorio.atualizar(uid, registro);
      } else {
        await _repositorio.criar(uid, registro);
      }
      _registros = await _repositorio.listar(uid);
      notifyListeners();
      return null;
    } on FalhaSonoLeve catch (falha) {
      return falha.mensagem;
    }
  }

  Future<String?> excluir(String idRegistro) async {
    final uid = _uid;
    if (uid == null) return null;
    try {
      await _repositorio.excluir(uid, idRegistro);
      _registros = _registros.where((r) => r.id != idRegistro).toList();
      notifyListeners();
      return null;
    } on FalhaSonoLeve catch (falha) {
      return falha.mensagem;
    }
  }

  /// Ao sair da conta.
  void limpar() {
    _uid = null;
    _registros = const [];
    notifyListeners();
  }
}
