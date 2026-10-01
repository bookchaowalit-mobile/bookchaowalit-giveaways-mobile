import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Giveaways', style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
              'Collect giveaway entrants and draw fair, duplicate-free winners.',
              style: textTheme.bodyLarge),
          const SizedBox(height: 16),
          Text('Features', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          const _Bullet(
              'Add entrants one by one or paste a list; duplicates are ignored (case-insensitive)'),
          const _Bullet('Draw any number of unique winners'),
          const _Bullet(
              'Seedable random source for reproducible draws in tests'),
          const SizedBox(height: 16),
          Text('Privacy', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'Everything runs on this device. The app has no account, '
            'analytics or network calls, and data is kept only for the '
            'current session.',
          ),
          const SizedBox(height: 16),
          Text('Made by Chaowalit Greepoke · bookchaowalit.com',
              style: textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
