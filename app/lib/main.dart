import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/tema/cores.dart';
import 'dados/firebase/configuracao_firebase.dart';
import 'injecao/dependencias.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Barra de status discreta sobre o fundo escuro.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: CoresSonoLeve.fundo,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  try {
    await iniciarFirebase();
    runApp(AppSonoLeve(dependencias: await Dependencias.firebase()));
  } catch (erro, pilha) {
    debugPrint('Inicialização do SonoLeve: $erro');
    debugPrintStack(stackTrace: pilha);
    runApp(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        home: Scaffold(
          backgroundColor: CoresSonoLeve.fundo,
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Não foi possível iniciar o Firebase. Confira a configuração no README.',
                style: TextStyle(color: CoresSonoLeve.texto),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
