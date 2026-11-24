/// Utilitários de data usados pelas regras de negócio.
abstract final class Datas {
  /// Remove horas/minutos: compara apenas o dia (RN03, RN07).
  static DateTime soDia(DateTime data) =>
      DateTime(data.year, data.month, data.day);

  static bool mesmoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Chave textual de um dia: "2026-11-10" (usada no checklist local).
  static String chaveDia(DateTime data) {
    final d = soDia(data);
    final mes = d.month.toString().padLeft(2, '0');
    final dia = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mes-$dia';
  }

  /// Os últimos [quantidade] dias, do mais antigo ao mais recente (hoje incluso).
  static List<DateTime> ultimosDias(DateTime referencia, int quantidade) {
    // DateTime(ano, mes, dia - n) normaliza o calendário e evita o erro de
    // subtrair 24h em fusos com horário de verão.
    return List<DateTime>.generate(
      quantidade,
      (i) => DateTime(
        referencia.year,
        referencia.month,
        referencia.day - (quantidade - 1 - i),
      ),
    );
  }
}
