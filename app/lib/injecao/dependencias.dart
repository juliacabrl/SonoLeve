import '../dados/mock/mock_repositorios.dart';
import '../dominio/repositorios/repositorios.dart';
import '../dominio/servicos/conectividade.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dados/firebase/repositorios_firebase.dart';
import '../dados/local/repositorios_locais.dart';

/// Seleciona a camada de dados usada pelas telas.
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
      auth: MockAuthRepository(
        conectividade: conectividade,
        latencia: latencia,
      ),
      registros: MockRegistroSonoRepository(latencia: latencia),
      conteudo: MockConteudoRepository(
        conectividade: conectividade,
        latencia: latencia,
      ),
      checklist: MockChecklistRepository(),
      preferencias: MockPreferenciasRepository(),
    );
  }

  static Future<Dependencias> firebase() async {
    final auth = FirebaseAuth.instance;
    final locais = await SharedPreferences.getInstance();
    final rede = Connectivity();
    return Dependencias(
      conectividade: ConectividadeDispositivo(
        rede,
        await rede.checkConnectivity(),
      ),
      auth: AuthFirebase(auth),
      registros: DiarioFirestore(FirebaseFirestore.instance),
      conteudo: CatalogoLocal(),
      checklist: ChecklistLocal(locais, () => auth.currentUser?.uid),
      preferencias: PreferenciasLocais(locais),
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
