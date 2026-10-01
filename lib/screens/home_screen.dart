import 'dart:math';

import 'package:flutter/material.dart';

import '../logic/draw.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.random});

  /// Optional seeded source for deterministic tests.
  final Random? random;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _entrants = EntrantList();
  final _input = TextEditingController();
  int _winnerCount = 1;
  List<String> _winners = [];
  String? _message;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _addEntrants() {
    final parts = _input.text
        .split(RegExp(r'[\n,;]'))
        .where((p) => p.trim().isNotEmpty)
        .length;
    final added = _entrants.addAll(_input.text);
    setState(() {
      _input.clear();
      final skipped = parts - added;
      _message = 'Added $added'
          '${skipped > 0 ? ', skipped $skipped duplicate or invalid' : ''}';
    });
  }

  void _draw() {
    setState(() {
      _winners = drawWinners(
        _entrants.names,
        _winnerCount,
        random: widget.random,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final canDraw = _entrants.length >= _winnerCount && _entrants.length > 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Giveaways')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const Key('entrant-input'),
            controller: _input,
            minLines: 1,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Entrant name(s)',
              helperText: 'One per line or comma-separated',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            key: const Key('add-entrants'),
            onPressed: _addEntrants,
            icon: const Icon(Icons.person_add),
            label: const Text('Add'),
          ),
          if (_message != null)
            Semantics(
              liveRegion: true,
              child: Text(_message!, key: const Key('add-message')),
            ),
          const SizedBox(height: 16),
          // Wrap (not Row) so large text sizes flow onto a second line
          // instead of overflowing on a phone.
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Semantics(
                liveRegion: true,
                child: Text(
                  'Winners: $_winnerCount',
                  style: textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Fewer winners',
                icon: const Icon(Icons.remove),
                onPressed: _winnerCount > 1
                    ? () => setState(() => _winnerCount--)
                    : null,
              ),
              IconButton(
                tooltip: 'More winners',
                icon: const Icon(Icons.add),
                onPressed: _winnerCount < _entrants.length
                    ? () => setState(() => _winnerCount++)
                    : null,
              ),
              FilledButton.icon(
                key: const Key('draw'),
                onPressed: canDraw ? _draw : null,
                icon: const Icon(Icons.casino),
                label: const Text('Draw'),
              ),
            ],
          ),
          if (_winners.isNotEmpty) ...[
            Text('Winners', style: textTheme.titleMedium),
            for (var i = 0; i < _winners.length; i++)
              ListTile(
                leading: CircleAvatar(
                  child: Text('${i + 1}', semanticsLabel: 'Winner ${i + 1}'),
                ),
                title: Text(_winners[i], key: Key('winner-$i')),
              ),
          ],
          const SizedBox(height: 16),
          Text(
            'Entrants (${_entrants.length})',
            style: textTheme.titleMedium,
          ),
          for (final n in _entrants.names)
            ListTile(
              dense: true,
              title: Text(n),
              trailing: IconButton(
                tooltip: 'Remove $n',
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _entrants.remove(n);
                  _winners = [];
                  if (_winnerCount > _entrants.length && _winnerCount > 1) {
                    _winnerCount = _entrants.length;
                  }
                }),
              ),
            ),
        ],
      ),
    );
  }
}
