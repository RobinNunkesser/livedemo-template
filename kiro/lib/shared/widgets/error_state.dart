import 'package:flutter/material.dart';

/// Wiederverwendbarer Fehlerzustand mit optionalem Retry-Button.
/// Laut A8 / SP1-08: Fehlermeldung + "Neu laden"-Schaltfläche.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.message = 'Die Daten konnten gerade nicht geladen werden.\n'
        'Bitte später versuchen.',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
              semanticLabel: 'Fehler',
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Neu laden'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
