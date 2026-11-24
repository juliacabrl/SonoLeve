import 'package:flutter/foundation.dart';

import '../core/rotas/rotas.dart';

/// Aba selecionada na barra inferior (Hoje · Relaxar · Diário).
class NavegacaoController extends ChangeNotifier {
  AbaPrincipal _aba = AbaPrincipal.hoje;

  AbaPrincipal get aba => _aba;

  void ir(AbaPrincipal aba) {
    if (_aba == aba) return;
    _aba = aba;
    notifyListeners();
  }
}
