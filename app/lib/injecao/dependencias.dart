import '../dados/mock/mock_repositorios.dart';
import '../dominio/repositorios/repositorios.dart';
import '../dominio/servicos/conectividade.dart';

/// Ponto ÚNICO onde o app decide de onde vêm os dados.
///
/// Protótipo de baixa fidelidade: [Dependencias.mock].
/// Próxima etapa: criar `Dependencias.firebase()` com as implementações em
/// `dados/firebase/` (Auth, Firestore, Storage, shared_preferences) e trocar
/// a chamada em `main.dart`. Telas e controllers não mudam.
class Dependencias {
  const Dependencias({
    required this.conectividade,
    required this.auth,
    required this.registros,
    required this.conteudo,
    required this.checklist,
    required this.preferencias,
  });

  /// Dados em memória. [latencia] simula a rede (use `Duration.zero` em testes).
  factory Dependencias.mock({
    Duration latencia = const Duration(milliseconds: 450),
    bool online = true,
  }) {
    final conectividade = ConectividadeSimulada(online: online);
    return Dependencias(
      conectividade: conectividade,
      auth:
          MockAuthRepository(conectividade: conectividade, latencia: latencia),
      registros: MockRegistroSonoRepository(latencia: latencia),
      conteudo: MockConteudoRepository(
          conectividade: conectividade, latencia: latencia),
      checklist: MockChecklistRepository(),
      preferencias: MockPreferenciasRepository(),
    );
  }

  final Conectividade conectividade;
  final AuthRepository auth;
  final RegistroSonoRepository registros;
  final ConteudoRepository conteudo;
  final ChecklistRepository checklist;
  final PreferenciasRepository preferencias;

  /// Disponível apenas nos dados mockados (Preferências → "Simular modo offline").
  ConectividadeSimulada? get conectividadeSimulada {
    final c = conectividade;
    return c is ConectividadeSimulada ? c : null;
  }
}
