import 'package:flutter/material.dart';

/// Wiederverwendbarer Ladezustand – wird in allen Feature-Screens eingesetzt.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message = 'Wird geladen…'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            semanticsLabel: message,
          ),
        ],
      ),
    );
  }
}
