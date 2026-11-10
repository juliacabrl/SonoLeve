import '../../core/utils/datas.dart';
import '../../dominio/modelos/conteudo.dart';
import '../../dominio/modelos/registro_sono.dart';

/// Dados de exemplo do protótipo, baseados nos textos de `prototype/figma`.
abstract final class DadosMock {
  static final DateTime _publicacao1 = DateTime(2026, 9, 1);
  static final DateTime _publicacao2 = DateTime(2026, 11, 10);

  // ---------------------------------------------------------------------------
  // Usuário de demonstração (persona prioritária)
  // ---------------------------------------------------------------------------
  static const String uidDemo = 'uid-jennifer';
  static const String nomeDemo = 'Jennifer Lopes';
  static const String emailDemo = 'jennifer@sonoleve.app';
  static const String senhaDemo = '123456';

  // ---------------------------------------------------------------------------
  // Catálogo EMBARCADO no app (versão 1) — garante o 1º uso offline.
  // ---------------------------------------------------------------------------
  static List<Som> get _sonsBase => [
        Som(
          id: 'chuva_suave',
          ordem: 1,
          ativo: true,
          atualizadoEm: _publicacao1,
          nome: 'Chuva suave',
          descricao: 'Gotas que desaceleram o dia',
          icone: 'chuva',
          caminhoStorage: 'sons/chuva_suave.mp3',
          duracaoSeg: 120,
          tamanhoBytes: 950000,
          caminhoLocal: 'asset://audios/chuva_suave.mp3',
        ),
        Som(
          id: 'ondas_mar',
          ordem: 2,
          ativo: true,
          atualizadoEm: _publicacao1,
          nome: 'Ondas do mar',
          descricao: 'O ritmo tranquilo da maré',
          icone: 'ondas',
          caminhoStorage: 'sons/ondas_mar.mp3',
          duracaoSeg: 150,
          tamanhoBytes: 1100000,
          caminhoLocal: 'asset://audios/ondas_mar.mp3',
        ),
        Som(
          id: 'vento_folhas',
          ordem: 3,
          ativo: true,
          atualizadoEm: _publicacao1,
          nome: 'Vento nas folhas',
          descricao: 'Uma brisa, sem pressa',
          icone: 'vento',
          caminhoStorage: 'sons/vento_folhas.mp3',
          duracaoSeg: 140,
          tamanhoBytes: 980000,
          caminhoLocal: 'asset://audios/vento_folhas.mp3',
        ),
      ];

  static List<ItemHabito> get _habitos => [
        ItemHabito(
            id: 'luz',
            ordem: 1,
            ativo: true,
            atualizadoEm: _publicacao1,
            titulo: 'Reduzir a luz do ambiente'),
        ItemHabito(
            id: 'celular',
            ordem: 2,
            ativo: true,
            atualizadoEm: _publicacao1,
            titulo: 'Deixar o celular de lado'),
        ItemHabito(
            id: 'lugar',
            ordem: 3,
            ativo: true,
            atualizadoEm: _publicacao1,
            titulo: 'Preparar um lugar tranquilo'),
        ItemHabito(
            id: 'tempo',
            ordem: 4,
            ativo: true,
            atualizadoEm: _publicacao1,
            titulo: 'Reservar um tempo para mim'),
      ];

  static List<SessaoRespiracao> get _respiracoes => [
        SessaoRespiracao(
          id: '4-7-8',
          ordem: 1,
          ativo: true,
          atualizadoEm: _publicacao1,
          nome: 'Respiração 4–7–8',
          descricao: 'Acompanhe um ritmo tranquilo',
          inspirarSeg: 4,
          segurarSeg: 7,
          expirarSeg: 8,
          ciclos: 4,
        ),
      ];

  static List<DicaHigieneSono> _dicas({required bool versaoNova}) => [
        DicaHigieneSono(
          id: 'ambiente',
          ordem: 1,
          ativo: true,
          atualizadoEm: versaoNova ? _publicacao2 : _publicacao1,
          titulo: 'Um cuidado para hoje',
          conteudo: versaoNova
              ? 'Deixe o quarto um pouco mais fresco e escuro.'
              : 'Prepare um ambiente tranquilo.',
        ),
        DicaHigieneSono(
          id: 'cafeina',
          ordem: 2,
          ativo: true,
          atualizadoEm: _publicacao1,
          titulo: 'Um cuidado para hoje',
          conteudo: 'Evite café e energéticos depois das 16h.',
        ),
        DicaHigieneSono(
          id: 'telas',
          ordem: 3,
          ativo: true,
          atualizadoEm: _publicacao1,
          titulo: 'Um cuidado para hoje',
          conteudo: 'Guarde o celular meia hora antes de deitar.',
        ),
      ];

  static CatalogoConteudo get catalogoEmbarcado => CatalogoConteudo(
        versao: 1,
        sons: _sonsBase,
        dicas: _dicas(versaoNova: false),
        habitos: _habitos,
        respiracoes: _respiracoes,
      );

  // ---------------------------------------------------------------------------
  // Catálogo "REMOTO" (versão 2): simula uma publicação da equipe pelo
  // Console do Firebase — um som novo (ainda não baixado) e uma dica editada.
  // ---------------------------------------------------------------------------
  static CatalogoConteudo get catalogoRemoto => CatalogoConteudo(
        versao: 2,
        sons: [
          // No servidor, nenhum som tem caminho local: isso é do aparelho.
          for (final som in _sonsBase) som.comCaminhoLocal(null),
          Som(
            id: 'lareira',
            ordem: 4,
            ativo: true,
            atualizadoEm: _publicacao2,
            nome: 'Lareira acesa',
            descricao: 'Estalos baixinhos e aconchego',
            icone: 'lareira',
            caminhoStorage: 'sons/lareira.mp3',
            duracaoSeg: 160,
            tamanhoBytes: 1200000,
          ),
        ],
        dicas: _dicas(versaoNova: true),
        habitos: _habitos,
        respiracoes: _respiracoes,
      );

  // ---------------------------------------------------------------------------
  // Diário do sono de exemplo: 6 das últimas 7 noites (média ≈ 7h 10m).
  // ---------------------------------------------------------------------------
  static List<RegistroSono> registrosDemo(DateTime hoje) {
    final dias = Datas.ultimosDias(hoje, 7); // dias[6] = hoje
    // (índice do dia, horas, qualidade). A noite de dias[2] ficou sem registro.
    const noites = <(int, double, int)>[
      (0, 6.75, 3),
      (1, 7.5, 4),
      (3, 7.0, 3),
      (4, 8.0, 5),
      (5, 6.5, 3),
      (6, 7.25, 4),
    ];
    return [
      for (final (indice, horas, nota) in noites)
        RegistroSono(
          id: 'reg-demo-$indice',
          data: dias[indice],
          horasDormidas: horas,
          qualidade: nota,
          criadoEm: dias[indice].add(const Duration(hours: 7)),
          atualizadoEm: dias[indice].add(const Duration(hours: 7)),
        ),
    ];
  }
}
