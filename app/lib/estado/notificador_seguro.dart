import 'package:flutter/foundation.dart';

/// Evita `notifyListeners()` depois do `dispose()` — acontece quando uma
/// operação assíncrona (rede, timer) termina após a tela ou o app fechar.
mixin NotificadorSeguro on ChangeNotifier {
  bool _descartado = false;

  bool get descartado => _descartado;

  @override
  void notifyListeners() {
    if (!_descartado) super.notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }
}
