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
}
