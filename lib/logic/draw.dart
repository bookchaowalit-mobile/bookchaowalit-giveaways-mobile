/// Entrant list management and fair, duplicate-free winner draws.
library;

import 'dart:math';

import 'package:characters/characters.dart';

const maxNameLength = 80;

/// Zero-width space and BOM often ride along when names are pasted from web
/// pages or spreadsheets; they would make `Bob` and `Bob\u200B` different.
final _invisible = RegExp('[\u200B\uFEFF]');

class EntrantList {
  final List<String> _names = [];
  final Set<String> _keys = {};

  List<String> get names => List.unmodifiable(_names);
  int get length => _names.length;

  static String _clean(String name) =>
      name.replaceAll(_invisible, '').trim().replaceAll(RegExp(r'\s+'), ' ');

  static String _key(String name) => _clean(name).toLowerCase();

  /// Adds one entrant. Returns false for blank names or duplicates
  /// (compared case-insensitively with collapsed whitespace).
  bool add(String name) {
    final clean = _clean(name);
    // Grapheme clusters, so emoji and Thai combining marks count once.
    if (clean.isEmpty || clean.characters.length > maxNameLength) return false;
    if (!_keys.add(_key(clean))) return false;
    _names.add(clean);
    return true;
  }

  /// Adds every line / comma-separated name; returns how many were new.
  int addAll(String pasted) {
    var added = 0;
    for (final part in pasted.split(RegExp(r'[\n,;]'))) {
      if (add(part)) added++;
    }
    return added;
  }

  bool remove(String name) {
    final k = _key(name);
    if (!_keys.remove(k)) return false;
    _names.removeWhere((n) => _key(n) == k);
    return true;
  }

  void clear() {
    _names.clear();
    _keys.clear();
  }
}

/// Draws [count] distinct winners with a partial Fisher-Yates shuffle, which
/// gives every entrant the same chance. Uses [Random.secure] unless a seeded
/// [random] is passed (for reproducible tests).
List<String> drawWinners(List<String> entrants, int count, {Random? random}) {
  if (count < 1) throw ArgumentError.value(count, 'count', 'must be >= 1');
  if (count > entrants.length) {
    throw ArgumentError.value(
      count,
      'count',
      'cannot exceed the ${entrants.length} entrants',
    );
  }
  final rng = random ?? Random.secure();
  final pool = [...entrants];
  for (var i = 0; i < count; i++) {
    final j = i + rng.nextInt(pool.length - i);
    final tmp = pool[i];
    pool[i] = pool[j];
    pool[j] = tmp;
  }
  return pool.sublist(0, count);
}
