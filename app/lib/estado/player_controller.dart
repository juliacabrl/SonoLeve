import 'dart:async';

import 'package:flutter/foundation.dart';

import '../dominio/modelos/conteudo.dart';
import 'notificador_seguro.dart';

/// Player de sons em *loop* com desligamento automático.
///
/// PROTÓTIPO: a reprodução é simulada (nenhum áudio toca). Na alta
/// fidelidade, os métodos abaixo passam a delegar ao pacote `just_audio`
/// usando `Som.caminhoLocal` — a interface pública deste controller não muda.
class PlayerController extends ChangeNotifier with NotificadorSeguro {
  PlayerController({this.opcoesDesligar = const [15, 30, 60]});

  /// Minutos oferecidos para desligar automaticamente.
  final List<int> opcoesDesligar;

  Som? _som;
  bool _tocando = false;
  double _volume = 0.35;
  int? _desligarEmMinutos;
  Timer? _timerDesligar;

  Som? get som => _som;
  bool get tocando => _tocando;
  double get volume => _volume;
  int? get desligarEmMinutos => _desligarEmMinutos;

  /// Prepara um som sem tocar (o player abre "em pausa", como no protótipo).
  void preparar(Som som) {
    if (_som?.id == som.id) return;
    _som = som;
    _tocando = false;
    notifyListeners();
  }

  void alternarReproducao() {
    if (_som == null) return;
    _tocando = !_tocando;
    if (_tocando && _desligarEmMinutos != null) _agendarDesligamento();
    if (!_tocando) _timerDesligar?.cancel();
    notifyListeners();
  }

  void pausar() {
    if (!_tocando) return;
    _tocando = false;
    _timerDesligar?.cancel();
    notifyListeners();
  }

  void definirVolume(double valor) {
    _volume = valor.clamp(0.0, 1.0).toDouble();
    notifyListeners();
  }

  /// Desligado → 15 → 30 → 60 → desligado.
  void alternarDesligamento() {
    final atual = _desligarEmMinutos;
    if (atual == null) {
      _desligarEmMinutos = opcoesDesligar.first;
    } else {
      final indice = opcoesDesligar.indexOf(atual);
      _desligarEmMinutos = indice < 0 || indice == opcoesDesligar.length - 1
          ? null
          : opcoesDesligar[indice + 1];
    }
    if (_desligarEmMinutos == null) {
      _timerDesligar?.cancel();
    } else if (_tocando) {
      _agendarDesligamento();
    }
    notifyListeners();
  }

  /// Troca para o som anterior/seguinte entre os [disponiveis].
  void trocar(List<Som> disponiveis, {required bool proximo}) {
    final atual = _som;
    if (atual == null || disponiveis.length < 2) return;
    var indice = disponiveis.indexWhere((s) => s.id == atual.id);
    if (indice < 0) indice = 0;
    final novoIndice = (indice + (proximo ? 1 : -1)) % disponiveis.length;
    _som = disponiveis[
        novoIndice < 0 ? novoIndice + disponiveis.length : novoIndice];
    notifyListeners();
  }

  void _agendarDesligamento() {
    _timerDesligar?.cancel();
    final minutos = _desligarEmMinutos;
    if (minutos == null) return;
    _timerDesligar = Timer(Duration(minutes: minutos), () {
      _tocando = false;
      _desligarEmMinutos = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timerDesligar?.cancel();
    super.dispose();
  }
}
