import 'package:flutter/material.dart';

class ErrorWidgetCard extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorWidgetCard({Key? key, required this.message, this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Erreur', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          if (onRetry != null)
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}
