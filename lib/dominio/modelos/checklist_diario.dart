import '../../core/utils/datas.dart';
import 'conteudo.dart';

/// Progresso do ritual noturno em um dia (F01, RF01/RF02).
///
/// Guarda apenas os IDs dos hábitos concluídos; o título vem do catálogo
/// (`ItemHabito`). É gravado somente no dispositivo (RN07).
class ChecklistDiario {
  ChecklistDiario(
      {required DateTime data, Set<String> idsConcluidos = const <String>{}})
      : data = Datas.soDia(data),
        idsConcluidos = Set.unmodifiable(idsConcluidos);

  final DateTime data;
  final Set<String> idsConcluidos;

  bool estaConcluido(String idHabito) => idsConcluidos.contains(idHabito);

  /// Retorna um novo checklist com o hábito marcado/desmarcado.
  ChecklistDiario alternar(String idHabito) {
    final ids = Set<String>.of(idsConcluidos);
    if (!ids.remove(idHabito)) ids.add(idHabito);
    return ChecklistDiario(data: data, idsConcluidos: ids);
  }

  /// Quantos dos [habitosAtivos] estão concluídos. IDs de hábitos desativados
  /// no catálogo são ignorados (RN09).
  int concluidosEntre(List<ItemHabito> habitosAtivos) =>
      habitosAtivos.where((h) => idsConcluidos.contains(h.id)).length;

  /// Fração concluída (0 a 1) — "2 de 4".
  double progresso(List<ItemHabito> habitosAtivos) {
    if (habitosAtivos.isEmpty) return 0;
    return concluidosEntre(habitosAtivos) / habitosAtivos.length;
  }
}
