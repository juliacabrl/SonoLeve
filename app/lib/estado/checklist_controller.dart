import 'package:flutter/foundation.dart';

import '../core/utils/datas.dart';
import '../dominio/modelos/checklist_diario.dart';
import '../dominio/repositorios/repositorios.dart';
import 'notificador_seguro.dart';

/// Ritual noturno do dia — progresso gravado só no dispositivo (RN07).
class ChecklistController extends ChangeNotifier with NotificadorSeguro {
  ChecklistController(this._repositorio);

  final ChecklistRepository _repositorio;

  ChecklistDiario? _checklist;

  ChecklistDiario? get checklist => _checklist;

  /// Carrega o dia informado (normalmente hoje). Um novo dia começa vazio.
  Future<void> carregar(DateTime dia) async {
    final atual = _checklist;
    if (atual != null && Datas.mesmoDia(atual.data, dia)) return;
    _checklist = await _repositorio.carregar(dia);
    notifyListeners();
  }

  Future<void> alternar(String idHabito) async {
    final atual = _checklist;
    if (atual == null) return;
    final novo = atual.alternar(idHabito);
    _checklist = novo; // atualiza a tela antes de gravar (resposta imediata)
    notifyListeners();
    await _repositorio.salvar(novo);
  }

  void limpar() {
    _checklist = null;
    notifyListeners();
  }
}
