import 'package:flutter/material.dart';

class ErrorWidgetBox extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const ErrorWidgetBox({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              if (onRetry != null)
                ElevatedButton(
                    onPressed: onRetry, child: const Text('Neu laden'))
            ],
          ),
        ),
      );
}
