import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/datas.dart';
import '../../dominio/erros.dart';
import '../../dominio/modelos/checklist_diario.dart';
import '../../dominio/modelos/conteudo.dart';
import '../../dominio/modelos/preferencias_usuario.dart';
import '../../dominio/repositorios/repositorios.dart';

import '../../dominio/servicos/conectividade.dart';
import '../mock/dados_mock.dart';

class ConectividadeDispositivo extends Conectividade {
  ConectividadeDispositivo(
    Connectivity dispositivo,
    List<ConnectivityResult> inicial,
  ) : _online = !inicial.contains(ConnectivityResult.none) {
    _assinatura = dispositivo.onConnectivityChanged.listen((interfaces) {
      final online = !interfaces.contains(ConnectivityResult.none);
      if (online == _online) return;
      _online = online;
      notifyListeners();
    });
  }

  bool _online;
  late final StreamSubscription<List<ConnectivityResult>> _assinatura;

  @override
  bool get online => _online;

  @override
  void dispose() {
    unawaited(_assinatura.cancel());
    super.dispose();
  }
}

class CatalogoLocal implements ConteudoRepository {
  @override
  Future<CatalogoConteudo> carregarDoCache() async =>
      DadosMock.catalogoEmbarcado;

  @override
  Future<bool> sincronizar() async => false;

  @override
  Future<Som> baixarAudio(Som som) async => som;
}

class ChecklistLocal implements ChecklistRepository {
  ChecklistLocal(this._dados, this._uidAtual);

  final SharedPreferences _dados;
  final String? Function() _uidAtual;

  String get _prefixoChecklist => 'checklist_${_uidAtual()}_';
  String _chaveChecklist(DateTime dia) =>
      '$_prefixoChecklist${Datas.chaveDia(dia)}';

  @override
  Future<ChecklistDiario> carregar(DateTime dia) async => ChecklistDiario(
    data: dia,
    idsConcluidos: _dados.getStringList(_chaveChecklist(dia))?.toSet() ?? {},
  );

  @override
  Future<void> salvar(ChecklistDiario checklist) async {
    final gravou = await _dados.setStringList(
      _chaveChecklist(checklist.data),
      checklist.idsConcluidos.toList(),
    );
    if (!gravou) {
      throw const RegraNegocioException('Não foi possível salvar o checklist.');
    }
  }

  @override
  Future<void> limpar() async {
    final prefixo = _prefixoChecklist;
    for (final chave in _dados.getKeys().where(
      (chave) => chave.startsWith(prefixo),
    )) {
      await _dados.remove(chave);
    }
  }
}

class PreferenciasLocais implements PreferenciasRepository {
  PreferenciasLocais(this._dados);

  final SharedPreferences _dados;

  @override
  Future<PreferenciasUsuario> carregar(String uid) async {
    final texto = _dados.getString('preferencias_$uid');
    if (texto == null) return const PreferenciasUsuario();
    return PreferenciasUsuario.fromMap(
      jsonDecode(texto) as Map<String, Object?>,
    );
  }

  @override
  Future<void> salvar(String uid, PreferenciasUsuario preferencias) async {
    await _dados.setString(
      'preferencias_$uid',
      jsonEncode(preferencias.toMap()),
    );
  }

  @override
  Future<void> excluir(String uid) async {
    await _dados.remove('preferencias_$uid');
  }
}
