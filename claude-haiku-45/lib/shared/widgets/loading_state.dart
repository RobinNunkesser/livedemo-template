import 'package:flutter/material.dart';

/// Shared Loading State Widget
class LoadingState extends StatelessWidget {
  final String? message;

  const LoadingState({Key? key, this.message = 'Lädt...'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          if (message != null)
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
