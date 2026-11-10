import 'package:flutter/foundation.dart';

/// Estado da conexão, observável pelas telas (selo "Offline") e usado pelos
/// repositórios para decidir entre rede e cache.
///
/// No protótipo a conexão é simulada (Preferências → "Simular modo offline");
/// no produto final será implementada com o pacote `connectivity_plus`.
abstract class Conectividade extends ChangeNotifier {
  bool get online;
}

/// Conexão controlada manualmente — usada pelos dados mockados e pelos testes.
class ConectividadeSimulada extends Conectividade {
  ConectividadeSimulada({bool online = true}) : _online = online;

  bool _online;

  @override
  bool get online => _online;

  void definir({required bool online}) {
    if (_online == online) return;
    _online = online;
    notifyListeners();
  }
}
