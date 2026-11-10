import '../../core/utils/datas.dart';
import 'conversao.dart';

/// Entidade central do CRUD (RF06–RF10). Documento `usuarios/{uid}/registrosSono/{id}`.
class RegistroSono {
  RegistroSono({
    required this.id,
    required DateTime data,
    required this.horasDormidas,
    required this.qualidade,
    this.observacao = '',
    required this.criadoEm,
    required this.atualizadoEm,
  }) : data = Datas.soDia(data);

  /// Registro ainda não salvo (o id é definido pelo repositório).
  factory RegistroSono.novo({
    required DateTime data,
    required double horasDormidas,
    required int qualidade,
    String observacao = '',
    DateTime? agora,
  }) {
    final momento = agora ?? DateTime.now();
    return RegistroSono(
      id: '',
      data: data,
      horasDormidas: horasDormidas,
      qualidade: qualidade,
      observacao: observacao,
      criadoEm: momento,
      atualizadoEm: momento,
    );
  }

  static const int qualidadeMinima = 1; // RN01
  static const int qualidadeMaxima = 5; // RN01
  static const double horasMaximas = 24; // RN02
  static const int tamanhoMaximoObservacao = 280; // RN04

  /// Rótulos gentis para cada nota, exibidos abaixo das estrelas.
  static const Map<int, String> rotulosQualidade = {
    1: 'Difícil',
    2: 'Agitado',
    3: 'Razoável',
    4: 'Bom',
    5: 'Muito bom',
  };

  final String id;

  /// Noite de referência (apenas o dia; RN03).
  final DateTime data;
  final double horasDormidas;
  final int qualidade;
  final String observacao;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  bool get salvo => id.isNotEmpty;

  int get minutosDormidos => (horasDormidas * 60).round();

  String get rotuloQualidade => rotulosQualidade[qualidade] ?? '';

  /// Lista de problemas encontrados; vazia quando o registro é válido.
  /// Cobre RN01, RN02 e RN04 — a RN03 (um por dia) depende dos demais
  /// registros e é verificada pelo repositório.
  List<String> validar() {
    final problemas = <String>[];
    if (qualidade < qualidadeMinima || qualidade > qualidadeMaxima) {
      problemas.add('Escolha uma avaliação de 1 a 5 estrelas.');
    }
    if (horasDormidas <= 0 || horasDormidas > horasMaximas) {
      problemas.add('As horas dormidas precisam ficar entre 0 e 24.');
    }
    if (observacao.length > tamanhoMaximoObservacao) {
      problemas.add(
          'A observação pode ter até $tamanhoMaximoObservacao caracteres.');
    }
    if (Datas.soDia(data).isAfter(Datas.soDia(DateTime.now()))) {
      problemas.add('Não é possível registrar uma noite futura.');
    }
    return problemas;
  }

  bool valido() => validar().isEmpty;

  RegistroSono copyWith({
    String? id,
    DateTime? data,
    double? horasDormidas,
    int? qualidade,
    String? observacao,
    DateTime? atualizadoEm,
  }) =>
      RegistroSono(
        id: id ?? this.id,
        data: data ?? this.data,
        horasDormidas: horasDormidas ?? this.horasDormidas,
        qualidade: qualidade ?? this.qualidade,
        observacao: observacao ?? this.observacao,
        criadoEm: criadoEm,
        atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      );

  /// O `id` não é gravado como campo: ele é o ID do documento.
  Map<String, Object?> toMap() => {
        'data': data,
        'horasDormidas': horasDormidas,
        'qualidade': qualidade,
        'observacao': observacao,
        'criadoEm': criadoEm,
        'atualizadoEm': atualizadoEm,
      };

  factory RegistroSono.fromMap(String id, Map<String, Object?> mapa) =>
      RegistroSono(
        id: id,
        data: Conversao.data(mapa['data']),
        horasDormidas: Conversao.decimal(mapa['horasDormidas']),
        qualidade: Conversao.inteiro(mapa['qualidade']),
        observacao: Conversao.texto(mapa['observacao']),
        criadoEm: Conversao.data(mapa['criadoEm']),
        atualizadoEm: Conversao.data(mapa['atualizadoEm']),
      );
}
