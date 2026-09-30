import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:giveaways/logic/draw.dart';

void main() {
  test('EntrantList ignores blanks and case/space duplicates', () {
    final list = EntrantList();
    expect(list.add('Ada Lovelace'), isTrue);
    expect(list.add('  ada   lovelace '), isFalse);
    expect(list.add('   '), isFalse);
    expect(list.add('x' * 81), isFalse);
    expect(list.addAll('Bob\nCara, bob; Dan\n\n'), 3);
    expect(list.names, ['Ada Lovelace', 'Bob', 'Cara', 'Dan']);
    expect(list.remove('BOB'), isTrue);
    expect(list.remove('nobody'), isFalse);
    expect(list.add('Bob'), isTrue);
    list.clear();
    expect(list.length, 0);
  });

  test('drawWinners returns unique winners from the list', () {
    final entrants = List.generate(20, (i) => 'p$i');
    for (var seed = 0; seed < 50; seed++) {
      final w = drawWinners(entrants, 5, random: Random(seed));
      expect(w.toSet(), hasLength(5));
      expect(entrants.toSet().containsAll(w), isTrue);
    }
    expect(
        drawWinners(entrants, 20, random: Random(1)).toSet(), entrants.toSet());
  });

  test('seeded draws are reproducible and input is not mutated', () {
    final entrants = ['a', 'b', 'c', 'd'];
    final w1 = drawWinners(entrants, 2, random: Random(7));
    final w2 = drawWinners(entrants, 2, random: Random(7));
    expect(w1, w2);
    expect(entrants, ['a', 'b', 'c', 'd']);
  });

  test('draw is roughly uniform', () {
    final entrants = ['a', 'b', 'c', 'd'];
    final counts = {for (final e in entrants) e: 0};
    final rng = Random(42);
    for (var i = 0; i < 8000; i++) {
      final w = drawWinners(entrants, 1, random: rng).single;
      counts[w] = counts[w]! + 1;
    }
    for (final c in counts.values) {
      expect(c, inInclusiveRange(1800, 2200));
    }
  });

  test('invalid counts throw', () {
    expect(() => drawWinners(['a'], 0), throwsArgumentError);
    expect(() => drawWinners(['a'], 2), throwsArgumentError);
  });

  group('edge cases (pass 3)', () {
    test('invisible characters from pasted lists do not create duplicates', () {
      final list = EntrantList();
      expect(list.add('Bob'), isTrue);
      expect(list.add('Bob\u200B'), isFalse);
      expect(list.add('\uFEFFbob'), isFalse);
      expect(list.add('\u200B'), isFalse);
      expect(list.names, ['Bob']);
    });

    test('name limit counts visible characters', () {
      final list = EntrantList();
      expect(list.add('🎉' * maxNameLength), isTrue);
      expect(list.add('🎁' * (maxNameLength + 1)), isFalse);
      expect(list.add('สมชาย ใจดี'), isTrue);
      expect(list.add('สมชาย   ใจดี'), isFalse);
    });

    test('addAll with only separators adds nothing', () {
      final list = EntrantList();
      expect(list.addAll(''), 0);
      expect(list.addAll(',;\n , ;'), 0);
      expect(list.addAll('\r\nAnn\r\n'), 1);
      expect(list.names, ['Ann']);
    });

    test('drawing everyone returns a permutation', () {
      final entrants = ['a', 'b', 'c', 'd'];
      final w = drawWinners(entrants, 4, random: Random(3));
      expect(w.toSet(), entrants.toSet());
      expect(drawWinners(['solo'], 1), ['solo']);
    });

    test('empty list cannot be drawn from', () {
      expect(() => drawWinners(const [], 1), throwsArgumentError);
    });

    test('every position is uniform, not just the first', () {
      final entrants = ['a', 'b', 'c'];
      final rng = Random(42);
      final counts = <String, int>{};
      const runs = 6000;
      for (var i = 0; i < runs; i++) {
        final w = drawWinners(entrants, 2, random: rng);
        counts.update(w[1], (c) => c + 1, ifAbsent: () => 1);
      }
      for (final e in entrants) {
        expect(counts[e]! / runs, closeTo(1 / 3, 0.03), reason: e);
      }
    });
  });
}
