/// Conversões usadas pelos `fromMap()` dos modelos.
///
/// Aceitam `DateTime`, texto ISO-8601 e o `Timestamp` do Firestore (que tem o
/// método `toDate()`), sem que o domínio precise importar o pacote do Firebase.
abstract final class Conversao {
  static DateTime data(Object? valor) {
    if (valor is DateTime) return valor;
    if (valor is String) return DateTime.parse(valor);
    if (valor != null) {
      // Timestamp do Firestore.
      try {
        final Object? convertido = (valor as dynamic).toDate();
        if (convertido is DateTime) return convertido;
      } on NoSuchMethodError {
        // Não é um Timestamp: cai no erro abaixo.
      }
    }
    throw FormatException('Data inválida: $valor');
  }

  static int inteiro(Object? valor, {int padrao = 0}) =>
      valor is num ? valor.toInt() : padrao;

  static double decimal(Object? valor, {double padrao = 0}) =>
      valor is num ? valor.toDouble() : padrao;

  static String texto(Object? valor, {String padrao = ''}) =>
      valor is String ? valor : padrao;

  static bool booleano(Object? valor, {bool padrao = false}) =>
      valor is bool ? valor : padrao;
}
