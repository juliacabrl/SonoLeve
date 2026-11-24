import 'dart:async';

import 'package:flutter/foundation.dart';

import '../dominio/erros.dart';
import '../dominio/modelos/conteudo.dart';
import '../dominio/repositorios/repositorios.dart';
import '../dominio/servicos/conectividade.dart';
import 'notificador_seguro.dart';

/// Catálogo de conteúdo: sempre exibido a partir do cache e sincronizado em
/// segundo plano quando há conexão (RN08, RN09, RNF04).
class ConteudoController extends ChangeNotifier with NotificadorSeguro {
  ConteudoController(this._repositorio, this._conectividade) {
    _conectividade.addListener(_aoMudarConexao);
  }

  final ConteudoRepository _repositorio;
  final Conectividade _conectividade;

  CatalogoConteudo _catalogo = CatalogoConteudo.vazio;
  bool _carregando = true;
  bool _sincronizando = false;
  bool _iniciado = false;
  final Set<String> _baixando = {};

  CatalogoConteudo get catalogo => _catalogo;
  bool get carregando => _carregando;
  bool get sincronizando => _sincronizando;

  bool estaBaixando(String idSom) => _baixando.contains(idSom);

  Som? somPorId(String id) {
    for (final som in _catalogo.sons) {
      if (som.id == id) return som;
    }
    return null;
  }

  SessaoRespiracao? respiracaoPorId(String? id) {
    final ativas = _catalogo.respiracoesAtivas;
    if (ativas.isEmpty) return null;
    if (id == null) return ativas.first;
    for (final r in ativas) {
      if (r.id == id) return r;
    }
    return ativas.first;
  }

  /// Uma dica diferente a cada dia.
  DicaHigieneSono? dicaDoDia([DateTime? dia]) {
    final dicas = _catalogo.dicasAtivas;
    if (dicas.isEmpty) return null;
    final d = dia ?? DateTime.now();
    final diaDoAno = d.difference(DateTime(d.year)).inDays;
    return dicas[diaDoAno % dicas.length];
  }

  /// Exibe o cache imediatamente e sincroniza em segundo plano.
  Future<void> iniciar() async {
    if (!_iniciado) {
      _iniciado = true;
      _catalogo = await _repositorio.carregarDoCache();
      _carregando = false;
      notifyListeners();
    }
    unawaited(sincronizar());
  }

  /// Retorna `true` se o catálogo mudou. Falhas de conexão são silenciosas:
  /// o app simplesmente continua com o cache.
  Future<bool> sincronizar() async {
    if (_sincronizando || !_conectividade.online) return false;
    _sincronizando = true;
    notifyListeners();
    var mudou = false;
    try {
      mudou = await _repositorio.sincronizar();
      if (mudou) _catalogo = await _repositorio.carregarDoCache();
    } on FalhaSonoLeve {
      mudou = false;
    } finally {
      _sincronizando = false;
      notifyListeners();
    }
    return mudou;
  }

  /// Baixa o áudio de um som. Retorna a mensagem de erro, ou `null`.
  Future<String?> baixarSom(Som som) async {
    if (som.disponivelOffline || _baixando.contains(som.id)) return null;
    _baixando.add(som.id);
    notifyListeners();
    try {
      await _repositorio.baixarAudio(som);
      _catalogo = await _repositorio.carregarDoCache();
      return null;
    } on FalhaSonoLeve catch (falha) {
      return falha is FalhaConexaoException
          ? 'Este som fica disponível quando você estiver conectado.'
          : falha.mensagem;
    } finally {
      _baixando.remove(som.id);
      notifyListeners();
    }
  }

  void _aoMudarConexao() {
    // Voltou a internet: aproveita para buscar novidades.
    if (_conectividade.online && _iniciado) unawaited(sincronizar());
    notifyListeners();
  }

  @override
  void dispose() {
    _conectividade.removeListener(_aoMudarConexao);
    super.dispose();
  }
}
