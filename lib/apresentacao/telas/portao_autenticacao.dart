import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../estado/auth_controller.dart';
import '../componentes/componentes.dart';
import 'login/tela_login.dart';
import 'shell_principal.dart';

/// Decide o que mostrar conforme a sessão: abertura, login ou o app.
class PortaoAutenticacao extends StatelessWidget {
  const PortaoAutenticacao({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return switch (auth.estado) {
      EstadoSessao.verificando => const Scaffold(
          body: Center(
              child:
                  AneisConcentricos(child: IconeAneis(Icons.bedtime_outlined))),
        ),
      EstadoSessao.deslogado => const TelaLogin(),
      // A chave recria o app (e recarrega os dados) a cada novo usuário.
      EstadoSessao.logado => ShellPrincipal(key: ValueKey(auth.usuario?.uid)),
    };
  }
}
