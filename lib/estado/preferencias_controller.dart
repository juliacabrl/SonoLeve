import 'package:flutter/foundation.dart';

import '../dominio/modelos/preferencias_usuario.dart';
import '../dominio/repositorios/repositorios.dart';
import 'notificador_seguro.dart';

/// Preferências do usuário (aparência, horário noturno, movimento).
class PreferenciasController extends ChangeNotifier with NotificadorSeguro {
  PreferenciasController(this._repositorio);

  final PreferenciasRepository _repositorio;

  String? _uid;
  PreferenciasUsuario _preferencias = const PreferenciasUsuario();

  PreferenciasUsuario get preferencias => _preferencias;

  Future<void> carregar(String uid) async {
    _uid = uid;
    _preferencias = await _repositorio.carregar(uid);
    notifyListeners();
  }

  Future<void> atualizar(PreferenciasUsuario novas) async {
    _preferencias = novas;
    notifyListeners();
    final uid = _uid;
    if (uid != null) await _repositorio.salvar(uid, novas);
  }

  void limpar() {
    _uid = null;
    _preferencias = const PreferenciasUsuario();
    notifyListeners();
  }
}
