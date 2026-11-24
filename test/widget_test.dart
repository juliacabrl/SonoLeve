import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sonoleve/app.dart';
import 'package:sonoleve/injecao/dependencias.dart';

/// Fluxos principais do protótipo, de ponta a ponta, com dados mockados.
void main() {
  Future<void> abrirApp(WidgetTester tester) async {
    // Mesma resolução dos protótipos do Figma: 390 x 844.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
        AppSonoLeve(dependencias: Dependencias.mock(latencia: Duration.zero)));
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, Finder alvo) async {
    await tester.ensureVisible(alvo);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();
  }

  Future<void> entrar(WidgetTester tester) async {
    expect(find.text('Entrar'), findsOneWidget);
    await tocar(tester, find.text('Entrar'));
    expect(find.text('O dia pode\nficar lá fora.'), findsOneWidget);
  }

  testWidgets('login com a conta de demonstração abre a Home', (tester) async {
    await abrirApp(tester);
    await entrar(tester);
    expect(find.text('Começar a relaxar'), findsOneWidget);
  });

  testWidgets('senha incorreta mostra um aviso e não entra', (tester) async {
    await abrirApp(tester);
    await tester.enterText(find.byType(TextField).last, 'errada');
    await tocar(tester, find.text('Entrar'));
    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
    expect(find.text('O dia pode\nficar lá fora.'), findsNothing);
  });

  testWidgets('ritual noturno: marcar um hábito atualiza o progresso',
      (tester) async {
    await abrirApp(tester);
    await entrar(tester);
    await tocar(tester, find.text('Meu ritual'));
    expect(find.text('0 de 4'), findsOneWidget);

    await tocar(tester, find.text('Reduzir a luz do ambiente'));
    expect(find.text('1 de 4'), findsOneWidget);
  });

  testWidgets('aba Relaxar lista os sons do catálogo', (tester) async {
    await abrirApp(tester);
    await entrar(tester);
    await tocar(tester, find.text('Relaxar'));
    expect(find.text('Encontre o\nseu silêncio.'), findsOneWidget);
    expect(find.text('Chuva suave'), findsOneWidget);
    // Som publicado na versão 2 do catálogo, ainda não baixado.
    expect(find.text('Lareira acesa'), findsOneWidget);
  });

  testWidgets(
      'diário: mostra a média semanal e impede duas noites no mesmo dia (RN03)',
      (tester) async {
    await abrirApp(tester);
    await entrar(tester);
    await tocar(tester, find.text('Diário'));
    expect(find.text('7h 10m'), findsOneWidget);
    expect(find.text('6 noites'), findsOneWidget);

    await tocar(tester, find.text('Registrar minha noite'));
    expect(find.text('Como foi\na sua noite?'), findsOneWidget);
    // A demonstração já tem a noite de hoje registrada.
    expect(find.text('Você já registrou esta noite.'), findsOneWidget);
  });
}
