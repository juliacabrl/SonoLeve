import 'conversao.dart';

/// Conta autenticada (Firebase Auth). O [uid] é a chave de todos os dados pessoais.
class Usuario {
  const Usuario({
    required this.uid,
    required this.nome,
    required this.email,
    required this.criadoEm,
  });

  final String uid;
  final String nome;
  final String email;
  final DateTime criadoEm;

  /// Primeiro nome, para saudações.
  String get primeiroNome {
    final partes = nome.trim().split(RegExp(r'\s+'));
    return partes.isEmpty || partes.first.isEmpty ? nome : partes.first;
  }

  Usuario copyWith({String? nome}) => Usuario(
      uid: uid, nome: nome ?? this.nome, email: email, criadoEm: criadoEm);

  /// Documento `usuarios/{uid}` (sem o mapa de preferências, gravado à parte).
  Map<String, Object?> toMap() => {
        'nome': nome,
        'email': email,
        'criadoEm': criadoEm,
      };

  factory Usuario.fromMap(String uid, Map<String, Object?> mapa) => Usuario(
        uid: uid,
        nome: Conversao.texto(mapa['nome']),
        email: Conversao.texto(mapa['email']),
        criadoEm: Conversao.data(mapa['criadoEm']),
      );
}
