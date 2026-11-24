import 'package:flutter_test/flutter_test.dart';
import 'package:sonoleve/core/utils/datas.dart';
import 'package:sonoleve/dados/mock/dados_mock.dart';
import 'package:sonoleve/dados/mock/mock_repositorios.dart';
import 'package:sonoleve/dominio/erros.dart';
import 'package:sonoleve/dominio/modelos/checklist_diario.dart';
import 'package:sonoleve/dominio/modelos/conteudo.dart';
import 'package:sonoleve/dominio/modelos/preferencias_usuario.dart';
import 'package:sonoleve/dominio/modelos/registro_sono.dart';
import 'package:sonoleve/dominio/modelos/resumo_semanal.dart';
import 'package:sonoleve/dominio/servicos/conectividade.dart';
import 'package:sonoleve/estado/respiracao_controller.dart';

void main() {
  final ontem = Datas.soDia(DateTime.now()).subtract(const Duration(days: 1));

  group('RegistroSono — regras de negócio', () {
    RegistroSono registro({double horas = 7, int nota = 4, String obs = ''}) =>
        RegistroSono.novo(
            data: ontem,
            horasDormidas: horas,
            qualidade: nota,
            observacao: obs);

    test('registro típico é válido', () {
      expect(registro().valido(), isTrue);
    });

    test('RN01: qualidade precisa estar entre 1 e 5', () {
      expect(registro(nota: 0).valido(), isFalse);
      expect(registro(nota: 6).valido(), isFalse);
      expect(registro(nota: 1).valido(), isTrue);
      expect(registro(nota: 5).valido(), isTrue);
    });

    test('RN02: horas precisam ser maiores que 0 e no máximo 24', () {
      expect(registro(horas: 0).valido(), isFalse);
      expect(registro(horas: 24.5).valido(), isFalse);
      expect(registro(horas: 24).valido(), isTrue);
    });

    test('RN04: observação limitada a 280 caracteres', () {
      expect(registro(obs: 'a' * 280).valido(), isTrue);
      expect(registro(obs: 'a' * 281).valido(), isFalse);
    });

    test('toMap/fromMap preservam os dados (id vem do documento)', () {
      final original = registro(obs: 'Acordei bem.').copyWith(id: 'abc');
      final copia = RegistroSono.fromMap('abc', original.toMap());
      expect(copia.id, 'abc');
      expect(copia.data, original.data);
      expect(copia.horasDormidas, original.horasDormidas);
      expect(copia.qualidade, original.qualidade);
      expect(copia.observacao, 'Acordei bem.');
      expect(original.toMap().containsKey('id'), isFalse);
    });
  });

  group('ResumoSemanal', () {
    test('dados de demonstração: 6 noites e média de 7h 10m', () {
      final hoje = DateTime.now();
      final resumo =
          ResumoSemanal.calcular(DadosMock.registrosDemo(hoje), hoje);
      expect(resumo.dias, hasLength(7));
      expect(resumo.quantidadeNoites, 6);
      expect(resumo.mediaMinutos, 7 * 60 + 10);
    });

    test('sem registros, a média é zero', () {
      final resumo = ResumoSemanal.calcular(const [], DateTime.now());
      expect(resumo.quantidadeNoites, 0);
      expect(resumo.mediaMinutos, 0);
    });
  });

  group('ChecklistDiario', () {
    final agora = DateTime(2026, 11, 10);
    ItemHabito habito(String id) => ItemHabito(
        id: id, ordem: 0, ativo: true, atualizadoEm: agora, titulo: id);

    test('alternar marca e desmarca', () {
      final c = ChecklistDiario(data: agora).alternar('luz');
      expect(c.estaConcluido('luz'), isTrue);
      expect(c.alternar('luz').estaConcluido('luz'), isFalse);
    });

    test('progresso ignora hábitos que saíram do catálogo', () {
      final c =
          ChecklistDiario(data: agora, idsConcluidos: {'luz', 'removido'});
      final ativos = [habito('luz'), habito('celular')];
      expect(c.concluidosEntre(ativos), 1);
      expect(c.progresso(ativos), 0.5);
    });
  });

  group('PreferenciasUsuario', () {
    test('horário noturno que atravessa a meia-noite (21:00 → 06:00)', () {
      const p = PreferenciasUsuario();
      expect(p.ehPeriodoNoturno(DateTime(2026, 1, 1, 22)), isTrue);
      expect(p.ehPeriodoNoturno(DateTime(2026, 1, 1, 3)), isTrue);
      expect(p.ehPeriodoNoturno(DateTime(2026, 1, 1, 12)), isFalse);
    });
  });

  group('MockRegistroSonoRepository (CRUD)', () {
    test('cria, edita e exclui', () async {
      final repo = MockRegistroSonoRepository();
      final criado = await repo.criar(
        'u1',
        RegistroSono.novo(data: ontem, horasDormidas: 7, qualidade: 4),
      );
      expect(criado.salvo, isTrue);
      await repo.atualizar('u1', criado.copyWith(qualidade: 5));
      expect((await repo.listar('u1')).single.qualidade, 5);
      await repo.excluir('u1', criado.id);
      expect(await repo.listar('u1'), isEmpty);
    });

    test('RN03: não permite duas noites no mesmo dia', () async {
      final repo = MockRegistroSonoRepository();
      await repo.criar(
          'u1', RegistroSono.novo(data: ontem, horasDormidas: 7, qualidade: 4));
      await expectLater(
        repo.criar('u1',
            RegistroSono.novo(data: ontem, horasDormidas: 6, qualidade: 3)),
        throwsA(isA<RegraNegocioException>()),
      );
    });
  });

  group('MockConteudoRepository (catálogo remoto + cache)', () {
    test('começa com o conteúdo embarcado e sincroniza a versão nova',
        () async {
      final conexao = ConectividadeSimulada();
      final repo = MockConteudoRepository(conectividade: conexao);
      expect((await repo.carregarDoCache()).versao, 1);

      expect(await repo.sincronizar(), isTrue);
      final cache = await repo.carregarDoCache();
      expect(cache.versao, 2);
      // Som novo precisa ser baixado; os embarcados continuam offline.
      expect(cache.sons.firstWhere((s) => s.id == 'lareira').disponivelOffline,
          isFalse);
      expect(
          cache.sons.firstWhere((s) => s.id == 'chuva_suave').disponivelOffline,
          isTrue);

      // RN09: sem versão nova, não baixa de novo.
      expect(await repo.sincronizar(), isFalse);
    });

    test('offline: mantém o cache e recusa downloads', () async {
      final conexao = ConectividadeSimulada(online: false);
      final repo = MockConteudoRepository(conectividade: conexao);
      await expectLater(
          repo.sincronizar(), throwsA(isA<FalhaConexaoException>()));
      final som = (await repo.carregarDoCache()).sons.first;
      await expectLater(
          repo.baixarAudio(som), throwsA(isA<FalhaConexaoException>()));
    });
  });

  group('RespiracaoController', () {
    test('percorre inspirar → segurar → expirar e conclui', () async {
      final sessao = SessaoRespiracao(
        id: 'teste',
        ordem: 0,
        ativo: true,
        atualizadoEm: DateTime(2026),
        nome: 'Teste',
        descricao: '',
        inspirarSeg: 1,
        segurarSeg: 1,
        expirarSeg: 1,
        ciclos: 1,
      );
      final controller = RespiracaoController(sessao,
          intervalo: const Duration(milliseconds: 5));
      final fases = <FaseRespiracao>[];
      controller.addListener(() {
        if (fases.isEmpty || fases.last != controller.fase) {
          fases.add(controller.fase);
        }
      });

      controller.iniciar();
      await Future<void>.delayed(const Duration(milliseconds: 150));

      expect(fases, [
        FaseRespiracao.inspirar,
        FaseRespiracao.segurar,
        FaseRespiracao.expirar,
        FaseRespiracao.concluida,
      ]);
      controller.dispose();
    });
  });
}
