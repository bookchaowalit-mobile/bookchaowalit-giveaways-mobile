import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:giveaways/main.dart';
import 'package:giveaways/screens/home_screen.dart';

void main() {
  testWidgets('app shell shows draw and about tab', (tester) async {
    await tester.pumpWidget(const GiveawaysApp());
    expect(find.text('Giveaways'), findsWidgets);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('Features'), findsOneWidget);
  });

  testWidgets('paste entrants, skip duplicates and draw', (tester) async {
    await tester.pumpWidget(MaterialApp(home: HomeScreen(random: Random(3))));
    await tester.enterText(
      find.byKey(const Key('entrant-input')),
      'Ann\nBen\nann\nCat',
    );
    await tester.tap(find.byKey(const Key('add-entrants')));
    await tester.pump();
    expect(
      find.text('Added 3, skipped 1 duplicate or invalid'),
      findsOneWidget,
    );
    expect(find.text('Entrants (3)'), findsOneWidget);

    await tester.tap(find.byTooltip('More winners'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('draw')));
    await tester.pump();
    final w0 = tester.widget<Text>(find.byKey(const Key('winner-0'))).data;
    final w1 = tester.widget<Text>(find.byKey(const Key('winner-1'))).data;
    expect(w0, isNot(w1));
    expect(['Ann', 'Ben', 'Cat'], containsAll([w0, w1]));
  });

  Widget home({double textScale = 1}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: HomeScreen(random: Random(1)),
        ),
      );

  testWidgets('lays out at 200% text scale on a phone without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(home(textScale: 2));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('entrant-input')), 'Ann, Bob');
    await tester.tap(find.byKey(const Key('add-entrants')));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('add reports skipped duplicates and draw needs entrants', (
    tester,
  ) async {
    await tester.pumpWidget(home());
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('draw'))).onPressed,
      isNull,
    );
    await tester.enterText(
      find.byKey(const Key('entrant-input')),
      'Ann\nann\nBob\u200B\nBob',
    );
    await tester.tap(find.byKey(const Key('add-entrants')));
    await tester.pump();
    expect(
        find.text('Added 2, skipped 2 duplicate or invalid'), findsOneWidget);
  });

  testWidgets('removing entrants lowers the winner count', (tester) async {
    await tester.pumpWidget(home());
    await tester.enterText(find.byKey(const Key('entrant-input')), 'A, B, C');
    await tester.tap(find.byKey(const Key('add-entrants')));
    await tester.pump();
    await tester.tap(find.byTooltip('More winners'));
    await tester.tap(find.byTooltip('More winners'));
    await tester.pump();
    expect(find.text('Winners: 3'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove A'));
    await tester.pump();
    expect(find.text('Winners: 2'), findsOneWidget);
    await tester.tap(find.byKey(const Key('draw')));
    await tester.pump();
    expect(find.byKey(const Key('winner-1')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('meets tap-target, label and contrast guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(home());
    await tester.enterText(find.byKey(const Key('entrant-input')), 'Ann, Bob');
    await tester.tap(find.byKey(const Key('add-entrants')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('draw')));
    await tester.pump();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    expect(find.bySemanticsLabel(RegExp('^Winner 1')), findsOneWidget);
    handle.dispose();
  });
}
