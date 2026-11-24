import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../dominio/modelos/conteudo.dart';
import 'notificador_seguro.dart';

/// Reproduz os sons embarcados em loop e controla o temporizador.
class PlayerController extends ChangeNotifier with NotificadorSeguro {
  PlayerController({AudioPlayer? audio}) : _audio = audio;

  // Testes de widgets usam o estado do player sem chamar código nativo.
  final AudioPlayer? _audio;
  final opcoesDesligar = const [15, 30, 60];

  Som? _som;
  bool _tocando = false;
  bool _ocupado = false;
  double _volume = 0.35;
  int? _desligarEmMinutos;
  Timer? _timerDesligar;
  String? _erro;

  Som? get som => _som;
  bool get tocando => _tocando;
  bool get ocupado => _ocupado;
  double get volume => _volume;
  int? get desligarEmMinutos => _desligarEmMinutos;
  String? get erro => _erro;

  Future<void> preparar(Som som) async {
    if (_som?.id == som.id) return;
    _som = som;
    await pausar();
  }

  Future<void> alternarReproducao() async {
    final som = _som;
    if (som == null || _ocupado) return;
    if (_tocando) {
      await pausar();
      return;
    }
    _ocupado = true;
    _erro = null;
    notifyListeners();
    try {
      final audio = _audio;
      if (audio != null) {
        final caminho = som.caminhoLocal;
        if (caminho == null || !caminho.startsWith('asset://')) {
          throw const FormatException('Som sem arquivo embarcado.');
        }
        await audio.setAsset(caminho.substring('asset://'.length));
        if (!_ocupado || _som != som || descartado) return;
        await audio.setLoopMode(LoopMode.one);
        await audio.setVolume(_volume);
        if (!_ocupado || _som != som || descartado) return;
        // play() só termina quando a faixa pausa, para ou acaba.
        unawaited(
          audio.play().catchError((Object erro) {
            if (_som == som && _tocando) _falhou();
          }),
        );
      }
      _tocando = true;
      _agendarDesligamento();
    } on Exception {
      if (_som == som && _ocupado) _falhou();
    } finally {
      if (_som == som) {
        _ocupado = false;
        notifyListeners();
      }
    }
  }

  Future<void> pausar() async {
    _tocando = false;
    _ocupado = false;
    _erro = null;
    _timerDesligar?.cancel();
    notifyListeners();
    try {
      await _audio?.stop();
    } on Exception {
      _falhou();
    }
  }

  Future<void> definirVolume(double valor) async {
    _volume = valor.clamp(0.0, 1.0).toDouble();
    notifyListeners();
    try {
      await _audio?.setVolume(_volume);
    } on Exception {
      _falhou();
    }
  }

  void alternarDesligamento() {
    final indice = opcoesDesligar.indexOf(_desligarEmMinutos ?? 0) + 1;
    _desligarEmMinutos = indice == opcoesDesligar.length
        ? null
        : opcoesDesligar[indice];
    _agendarDesligamento();
    notifyListeners();
  }

  Future<void> trocar(List<Som> disponiveis, {required bool proximo}) async {
    final atual = _som;
    if (atual == null || disponiveis.length < 2 || _ocupado) return;
    final indice = disponiveis.indexWhere((som) => som.id == atual.id);
    final novo = (indice + (proximo ? 1 : -1)) % disponiveis.length;
    final estavaTocando = _tocando;
    await preparar(disponiveis[novo]);
    if (estavaTocando && _som == disponiveis[novo] && !_tocando) {
      await alternarReproducao();
    }
  }

  void _agendarDesligamento() {
    _timerDesligar?.cancel();
    final minutos = _desligarEmMinutos;
    if (!_tocando || minutos == null) return;
    _timerDesligar = Timer(Duration(minutes: minutos), () {
      _desligarEmMinutos = null;
      unawaited(pausar());
    });
  }

  void _falhou() {
    _tocando = false;
    _timerDesligar?.cancel();
    _erro = 'Não foi possível reproduzir este som.';
    notifyListeners();
  }

  @override
  void dispose() {
    _timerDesligar?.cancel();
    final audio = _audio;
    if (audio != null) unawaited(audio.dispose());
    super.dispose();
  }
}
