import 'conversao.dart';

/// Configurações do app (RNF03, RF13). Mapa `preferencias` em `usuarios/{uid}`.
class PreferenciasUsuario {
  const PreferenciasUsuario({
    this.modoEscuro = true,
    this.temaAutomatico = true,
    this.horaInicioNoite = '21:00',
    this.horaFimNoite = '06:00',
    this.reduzirMovimento = true,
  });

  /// Escuro é o padrão (RNF03).
  final bool modoEscuro;

  /// Quando ativo, a paleta acompanha o horário noturno (RF13).
  final bool temaAutomatico;

  /// "HH:mm"
  final String horaInicioNoite;

  /// "HH:mm"
  final String horaFimNoite;

  /// Reduz animações (anéis da respiração, transições).
  final bool reduzirMovimento;

  static int minutosDe(String hora) {
    final partes = hora.split(':');
    if (partes.length != 2) return 0;
    final h = int.tryParse(partes[0]) ?? 0;
    final m = int.tryParse(partes[1]) ?? 0;
    return (h * 60 + m) % (24 * 60);
  }

  /// O horário noturno pode atravessar a meia-noite (21:00 → 06:00).
  bool ehPeriodoNoturno(DateTime agora) {
    final atual = agora.hour * 60 + agora.minute;
    final inicio = minutosDe(horaInicioNoite);
    final fim = minutosDe(horaFimNoite);
    if (inicio == fim) return true;
    return inicio < fim
        ? atual >= inicio && atual < fim
        : atual >= inicio || atual < fim;
  }

  PreferenciasUsuario copyWith({
    bool? modoEscuro,
    bool? temaAutomatico,
    String? horaInicioNoite,
    String? horaFimNoite,
    bool? reduzirMovimento,
  }) =>
      PreferenciasUsuario(
        modoEscuro: modoEscuro ?? this.modoEscuro,
        temaAutomatico: temaAutomatico ?? this.temaAutomatico,
        horaInicioNoite: horaInicioNoite ?? this.horaInicioNoite,
        horaFimNoite: horaFimNoite ?? this.horaFimNoite,
        reduzirMovimento: reduzirMovimento ?? this.reduzirMovimento,
      );

  Map<String, Object?> toMap() => {
        'modoEscuro': modoEscuro,
        'temaAutomatico': temaAutomatico,
        'horaInicioNoite': horaInicioNoite,
        'horaFimNoite': horaFimNoite,
        'reduzirMovimento': reduzirMovimento,
      };

  factory PreferenciasUsuario.fromMap(Map<String, Object?> mapa) =>
      PreferenciasUsuario(
        modoEscuro: Conversao.booleano(mapa['modoEscuro'], padrao: true),
        temaAutomatico:
            Conversao.booleano(mapa['temaAutomatico'], padrao: true),
        horaInicioNoite:
            Conversao.texto(mapa['horaInicioNoite'], padrao: '21:00'),
        horaFimNoite: Conversao.texto(mapa['horaFimNoite'], padrao: '06:00'),
        reduzirMovimento:
            Conversao.booleano(mapa['reduzirMovimento'], padrao: true),
      );
}
