import 'conversao.dart';

/// Base dos itens do catálogo global (somente leitura no app — RN08).
abstract class ItemConteudo {
  const ItemConteudo({
    required this.id,
    required this.ordem,
    required this.ativo,
    required this.atualizadoEm,
  });

  final String id;

  /// Posição de exibição.
  final int ordem;

  /// `false` oculta o item sem apagá-lo.
  final bool ativo;
  final DateTime atualizadoEm;
}

/// Som de relaxamento (F03). Metadados em `conteudo_sons`; áudio no Storage.
class Som extends ItemConteudo {
  const Som({
    required super.id,
    required super.ordem,
    required super.ativo,
    required super.atualizadoEm,
    required this.nome,
    required this.descricao,
    required this.icone,
    required this.caminhoStorage,
    required this.duracaoSeg,
    this.tamanhoBytes = 0,
    this.categoria = 'Natureza',
    this.caminhoLocal,
  });

  final String nome;
  final String descricao;

  /// Nome do ícone (ver `IconesConteudo`).
  final String icone;

  /// Ex.: `sons/chuva_suave.mp3`.
  final String caminhoStorage;
  final int duracaoSeg;
  final int tamanhoBytes;
  final String categoria;

  /// Arquivo no aparelho, depois do download (ou embarcado no app).
  final String? caminhoLocal;

  bool get disponivelOffline => caminhoLocal != null;

  Som comCaminhoLocal(String? caminho) => Som(
        id: id,
        ordem: ordem,
        ativo: ativo,
        atualizadoEm: atualizadoEm,
        nome: nome,
        descricao: descricao,
        icone: icone,
        caminhoStorage: caminhoStorage,
        duracaoSeg: duracaoSeg,
        tamanhoBytes: tamanhoBytes,
        categoria: categoria,
        caminhoLocal: caminho,
      );

  factory Som.fromMap(String id, Map<String, Object?> mapa) => Som(
        id: id,
        ordem: Conversao.inteiro(mapa['ordem']),
        ativo: Conversao.booleano(mapa['ativo'], padrao: true),
        atualizadoEm: Conversao.data(mapa['atualizadoEm']),
        nome: Conversao.texto(mapa['nome']),
        descricao: Conversao.texto(mapa['descricao']),
        icone: Conversao.texto(mapa['icone'], padrao: 'musica'),
        caminhoStorage: Conversao.texto(mapa['caminhoStorage']),
        duracaoSeg: Conversao.inteiro(mapa['duracaoSeg']),
        tamanhoBytes: Conversao.inteiro(mapa['tamanhoBytes']),
        categoria: Conversao.texto(mapa['categoria'], padrao: 'Natureza'),
      );
}

/// Dica de higiene do sono (F07). Coleção `conteudo_dicas`.
class DicaHigieneSono extends ItemConteudo {
  const DicaHigieneSono({
    required super.id,
    required super.ordem,
    required super.ativo,
    required super.atualizadoEm,
    required this.titulo,
    required this.conteudo,
  });

  final String titulo;
  final String conteudo;

  factory DicaHigieneSono.fromMap(String id, Map<String, Object?> mapa) =>
      DicaHigieneSono(
        id: id,
        ordem: Conversao.inteiro(mapa['ordem']),
        ativo: Conversao.booleano(mapa['ativo'], padrao: true),
        atualizadoEm: Conversao.data(mapa['atualizadoEm']),
        titulo: Conversao.texto(mapa['titulo']),
        conteudo: Conversao.texto(mapa['conteudo']),
      );
}

/// Hábito do checklist noturno (F01). Coleção `conteudo_habitos`.
class ItemHabito extends ItemConteudo {
  const ItemHabito({
    required super.id,
    required super.ordem,
    required super.ativo,
    required super.atualizadoEm,
    required this.titulo,
    this.descricao = '',
  });

  final String titulo;
  final String descricao;

  factory ItemHabito.fromMap(String id, Map<String, Object?> mapa) =>
      ItemHabito(
        id: id,
        ordem: Conversao.inteiro(mapa['ordem']),
        ativo: Conversao.booleano(mapa['ativo'], padrao: true),
        atualizadoEm: Conversao.data(mapa['atualizadoEm']),
        titulo: Conversao.texto(mapa['titulo']),
        descricao: Conversao.texto(mapa['descricao']),
      );
}

/// Técnica de respiração guiada (F02). Coleção `conteudo_respiracao`.
class SessaoRespiracao extends ItemConteudo {
  const SessaoRespiracao({
    required super.id,
    required super.ordem,
    required super.ativo,
    required super.atualizadoEm,
    required this.nome,
    required this.descricao,
    required this.inspirarSeg,
    required this.segurarSeg,
    required this.expirarSeg,
    required this.ciclos,
  });

  final String nome;
  final String descricao;
  final int inspirarSeg;
  final int segurarSeg;
  final int expirarSeg;
  final int ciclos;

  int get segundosPorCiclo => inspirarSeg + segurarSeg + expirarSeg;

  Duration duracaoTotal() => Duration(seconds: segundosPorCiclo * ciclos);

  factory SessaoRespiracao.fromMap(String id, Map<String, Object?> mapa) =>
      SessaoRespiracao(
        id: id,
        ordem: Conversao.inteiro(mapa['ordem']),
        ativo: Conversao.booleano(mapa['ativo'], padrao: true),
        atualizadoEm: Conversao.data(mapa['atualizadoEm']),
        nome: Conversao.texto(mapa['nome']),
        descricao: Conversao.texto(mapa['descricao']),
        inspirarSeg: Conversao.inteiro(mapa['inspirarSeg'], padrao: 4),
        segurarSeg: Conversao.inteiro(mapa['segurarSeg'], padrao: 7),
        expirarSeg: Conversao.inteiro(mapa['expirarSeg'], padrao: 8),
        ciclos: Conversao.inteiro(mapa['ciclos'], padrao: 4),
      );
}

/// Espelha `config/catalogo` (RN09).
class VersaoCatalogo {
  const VersaoCatalogo({required this.versao, required this.atualizadoEm});

  final int versao;
  final DateTime atualizadoEm;

  bool precisaSincronizar(int versaoLocal) => versao > versaoLocal;
}

/// O catálogo completo, como o app o enxerga (cache local).
class CatalogoConteudo {
  const CatalogoConteudo({
    required this.versao,
    required this.sons,
    required this.dicas,
    required this.habitos,
    required this.respiracoes,
  });

  static const vazio = CatalogoConteudo(
    versao: 0,
    sons: [],
    dicas: [],
    habitos: [],
    respiracoes: [],
  );

  final int versao;
  final List<Som> sons;
  final List<DicaHigieneSono> dicas;
  final List<ItemHabito> habitos;
  final List<SessaoRespiracao> respiracoes;

  static List<T> _ativos<T extends ItemConteudo>(List<T> itens) =>
      itens.where((i) => i.ativo).toList()
        ..sort((a, b) => a.ordem.compareTo(b.ordem));

  List<Som> get sonsAtivos => _ativos(sons);
  List<DicaHigieneSono> get dicasAtivas => _ativos(dicas);
  List<ItemHabito> get habitosAtivos => _ativos(habitos);
  List<SessaoRespiracao> get respiracoesAtivas => _ativos(respiracoes);

  CatalogoConteudo copyWith({int? versao, List<Som>? sons}) => CatalogoConteudo(
        versao: versao ?? this.versao,
        sons: sons ?? this.sons,
        dicas: dicas,
        habitos: habitos,
        respiracoes: respiracoes,
      );
}
