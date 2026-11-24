/// Formatação de datas e durações em português, sem dependências externas.
abstract final class Formatadores {
  static const List<String> _meses = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  static const List<String> _mesesCurtos = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];

  // DateTime.weekday: 1 = segunda ... 7 = domingo.
  static const List<String> _diasSemana = [
    'segunda',
    'terça',
    'quarta',
    'quinta',
    'sexta',
    'sábado',
    'domingo',
  ];

  static const List<String> _diasSemanaCurtos = [
    'seg',
    'ter',
    'qua',
    'qui',
    'sex',
    'sáb',
    'dom',
  ];

  static String _doisDigitos(int valor) => valor.toString().padLeft(2, '0');

  /// "21:48"
  static String hora(DateTime data) =>
      '${_doisDigitos(data.hour)}:${_doisDigitos(data.minute)}';

  /// "21:00" a partir de minutos desde a meia-noite.
  static String horaDeMinutos(int minutosDoDia) =>
      '${_doisDigitos(minutosDoDia ~/ 60)}:${_doisDigitos(minutosDoDia % 60)}';

  /// "TERÇA, 22 SETEMBRO · 21:48" — cabeçalho da Home.
  static String cabecalhoHoje(DateTime data) {
    final dia = _diasSemana[data.weekday - 1];
    final mes = _meses[data.month - 1];
    return '$dia, ${data.day} $mes · ${hora(data)}'.toUpperCase();
  }

  /// "qua"
  static String diaSemanaCurto(DateTime data) =>
      _diasSemanaCurtos[data.weekday - 1];

  /// "22 set"
  static String dataCurta(DateTime data) =>
      '${data.day} ${_mesesCurtos[data.month - 1]}';

  /// "22 de setembro de 2026"
  static String dataExtensa(DateTime data) =>
      '${data.day} de ${_meses[data.month - 1]} de ${data.year}';

  /// "7h 30" — usado na lista de noites ("7h 30 de descanso").
  static String duracaoCurta(int minutos) {
    final h = minutos ~/ 60;
    final m = minutos % 60;
    return m == 0 ? '${h}h' : '${h}h ${_doisDigitos(m)}';
  }

  /// "7h 10m" — usado na média semanal.
  static String duracaoMedia(int minutos) {
    final h = minutos ~/ 60;
    final m = minutos % 60;
    return '${h}h ${_doisDigitos(m)}m';
  }

  /// "7 h 00 min" — usado no contador de duração.
  static String duracaoContador(int minutos) {
    final h = minutos ~/ 60;
    final m = minutos % 60;
    return '$h h ${_doisDigitos(m)} min';
  }

  /// Plural simples: "1 noite", "6 noites".
  static String contagem(int quantidade, String singular, String plural) =>
      '$quantidade ${quantidade == 1 ? singular : plural}';
}
