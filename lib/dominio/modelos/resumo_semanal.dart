import '../../core/utils/datas.dart';
import 'registro_sono.dart';

/// Agregado calculado em memória para o gráfico semanal (RF11). Não é persistido.
class ResumoSemanal {
  ResumoSemanal._(this.dias, this._porDia);

  /// Resumo dos 7 dias que terminam em [referencia] (inclusive).
  factory ResumoSemanal.calcular(
      List<RegistroSono> registros, DateTime referencia) {
    final dias = Datas.ultimosDias(referencia, 7);
    final porDia = <DateTime, RegistroSono>{};
    for (final registro in registros) {
      final dia = Datas.soDia(registro.data);
      if (dias.any((d) => Datas.mesmoDia(d, dia))) porDia[dia] = registro;
    }
    return ResumoSemanal._(dias, porDia);
  }

  /// Os 7 dias, do mais antigo ao mais recente.
  final List<DateTime> dias;
  final Map<DateTime, RegistroSono> _porDia;

  DateTime get inicioSemana => dias.first;
  DateTime get fimSemana => dias.last;

  List<RegistroSono> get registros => _porDia.values.toList();

  int get quantidadeNoites => _porDia.length;

  RegistroSono? registroDo(DateTime dia) => _porDia[Datas.soDia(dia)];

  /// Média de minutos dormidos nas noites registradas (0 se nenhuma).
  int get mediaMinutos {
    if (_porDia.isEmpty) return 0;
    final total =
        _porDia.values.fold<int>(0, (soma, r) => soma + r.minutosDormidos);
    return (total / _porDia.length).round();
  }

  double get mediaHoras => mediaMinutos / 60;

  double get mediaQualidade {
    if (_porDia.isEmpty) return 0;
    final total = _porDia.values.fold<int>(0, (soma, r) => soma + r.qualidade);
    return total / _porDia.length;
  }
}
