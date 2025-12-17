import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Which language do you want to learn?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _LanguageCard(
              languageName: 'Mandarin',
              flag: '🇨🇳',
              onTap: () {
                Navigator.pushReplacementNamed(context, '/dashboard');
              },
            ),
            const SizedBox(height: 16),
            _LanguageCard(
              languageName: 'Spanish',
              flag: '🇪🇸',
              isComingSoon: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
            const SizedBox(height: 16),
            _LanguageCard(
              languageName: 'French',
              flag: '🇫🇷',
              isComingSoon: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String languageName;
  final String flag;
  final bool isComingSoon;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.languageName,
    required this.flag,
    this.isComingSoon = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: isComingSoon ? onTap : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Text(
                flag,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languageName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isComingSoon)
                      Text(
                        'Coming Soon',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                isComingSoon ? Icons.lock_outline : Icons.arrow_forward_ios,
                color: isComingSoon ? Colors.grey : Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}