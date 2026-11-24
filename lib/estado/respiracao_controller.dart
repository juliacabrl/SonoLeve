import 'dart:async';

import 'package:flutter/foundation.dart';

import '../dominio/modelos/conteudo.dart';
import 'notificador_seguro.dart';

enum FaseRespiracao { pronta, inspirar, segurar, expirar, concluida }

/// Conduz uma sessão de respiração guiada (F02), segundo a segundo.
///
/// Funciona totalmente offline: os parâmetros vêm do catálogo em cache.
class RespiracaoController extends ChangeNotifier with NotificadorSeguro {
  RespiracaoController(this.sessao,
      {this.intervalo = const Duration(seconds: 1)});

  final SessaoRespiracao sessao;

  /// Duração de um "segundo" — reduzida nos testes.
  final Duration intervalo;

  FaseRespiracao _fase = FaseRespiracao.pronta;
  int _segundosRestantes = 0;
  int _cicloAtual = 0;
  Timer? _timer;

  FaseRespiracao get fase => _fase;
  int get cicloAtual => _cicloAtual;

  /// Na fase "pronta", mostra a duração da inspiração.
  int get segundosRestantes =>
      _fase == FaseRespiracao.pronta ? sessao.inspirarSeg : _segundosRestantes;

  bool get emAndamento =>
      _fase == FaseRespiracao.inspirar ||
      _fase == FaseRespiracao.segurar ||
      _fase == FaseRespiracao.expirar;

  int duracaoDa(FaseRespiracao fase) => switch (fase) {
        FaseRespiracao.inspirar => sessao.inspirarSeg,
        FaseRespiracao.segurar => sessao.segurarSeg,
        FaseRespiracao.expirar => sessao.expirarSeg,
        _ => 0,
      };

  void iniciar() {
    _timer?.cancel();
    _cicloAtual = 1;
    _entrar(FaseRespiracao.inspirar);
    _timer = Timer.periodic(intervalo, (_) => _avancarSegundo());
  }

  void parar() {
    _timer?.cancel();
    _timer = null;
    _fase = FaseRespiracao.pronta;
    _cicloAtual = 0;
    notifyListeners();
  }

  void _entrar(FaseRespiracao fase) {
    _fase = fase;
    _segundosRestantes = duracaoDa(fase);
    notifyListeners();
  }

  void _avancarSegundo() {
    if (_segundosRestantes > 1) {
      _segundosRestantes--;
      notifyListeners();
      return;
    }
    switch (_fase) {
      case FaseRespiracao.inspirar:
        _entrar(FaseRespiracao.segurar);
      case FaseRespiracao.segurar:
        _entrar(FaseRespiracao.expirar);
      case FaseRespiracao.expirar:
        if (_cicloAtual < sessao.ciclos) {
          _cicloAtual++;
          _entrar(FaseRespiracao.inspirar);
        } else {
          _timer?.cancel();
          _timer = null;
          _fase = FaseRespiracao.concluida;
          notifyListeners();
        }
      case FaseRespiracao.pronta:
      case FaseRespiracao.concluida:
        _timer?.cancel();
        _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
