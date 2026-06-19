import 'package:flutter/material.dart';

/// Shared Error State Widget
class ErrorState extends StatelessWidget {
  final String message;
  final String? buttonLabel;
  final VoidCallback? onRetry;

  const ErrorState({
    Key? key,
    required this.message,
    this.buttonLabel = 'Erneut versuchen',
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(buttonLabel ?? 'Erneut versuchen'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
