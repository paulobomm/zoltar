import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zoltar/logic/game_engine.dart';
import 'package:zoltar/main.dart';
import 'package:zoltar/models/answer.dart';

void main() {
  testWidgets('mostra a tela inicial do Zoltar', (WidgetTester tester) async {
    await tester.pumpWidget(const ZoltarApp());

    expect(find.text('Zoltar o Grande!'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);
  });

  test('as respostas mudam a proxima pergunta escolhida', () {
    final simEngine = GameEngine(random: Random(7));
    final naoEngine = GameEngine(random: Random(7));

    final primeiraSim = simEngine.nextQuestion();
    final primeiraNao = naoEngine.nextQuestion();

    expect(primeiraSim.id, primeiraNao.id);

    simEngine.recordAnswer(primeiraSim, Answer.sim);
    naoEngine.recordAnswer(primeiraNao, Answer.nao);

    final proximaComSim = simEngine.nextQuestion();
    final proximaComNao = naoEngine.nextQuestion();

    expect(proximaComSim.id, isNot(proximaComNao.id));
  });
}
