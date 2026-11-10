import 'package:flutter/material.dart';

import 'cores.dart';
import 'tipografia.dart';

/// Tema global do SonoLeve: escuro por padrão (RNF03), poucos estímulos
/// visuais e sem efeitos de toque chamativos (RNF11).
abstract final class TemaApp {
  static ThemeData get escuro {
    // ColorScheme.dark mantém compatibilidade entre versões do Flutter
    // (os parâmetros obrigatórios do construtor padrão mudaram no 3.22).
    const esquema = ColorScheme.dark(
      primary: CoresSonoLeve.primaria,
      onPrimary: CoresSonoLeve.textoSobrePrimaria,
      secondary: CoresSonoLeve.lavanda,
      onSecondary: CoresSonoLeve.fundo,
      error: CoresSonoLeve.destaque,
      onError: CoresSonoLeve.fundo,
      surface: CoresSonoLeve.superficie,
      onSurface: CoresSonoLeve.texto,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: esquema,
      scaffoldBackgroundColor: CoresSonoLeve.fundo,
      canvasColor: CoresSonoLeve.fundo,
      fontFamily: TipografiaSonoLeve.familia,
      // Toques discretos: sem "onda" brilhante.
      splashFactory: NoSplash.splashFactory,
      highlightColor: CoresSonoLeve.brilho,
      dividerColor: CoresSonoLeve.borda,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: CoresSonoLeve.lavanda,
        selectionColor: CoresSonoLeve.lavandaSuave,
        selectionHandleColor: CoresSonoLeve.lavanda,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: CoresSonoLeve.superficie,
        contentTextStyle: TipografiaSonoLeve.corpoForte,
        behavior: SnackBarBehavior.floating,
      ),
      // Diálogos são estilizados em `apresentacao/componentes/dialogos.dart`
      // (o tipo de `dialogTheme` mudou entre versões do Flutter).
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: CoresSonoLeve.superficie,
        showDragHandle: true,
      ),
    );
  }
}
