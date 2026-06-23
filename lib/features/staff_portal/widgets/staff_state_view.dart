import 'package:flutter/material.dart';

class StaffLoadingState extends StatelessWidget {
  const StaffLoadingState({this.skeleton = false, super.key});

  final bool skeleton;

  @override
  Widget build(BuildContext context) {
    if (!skeleton) {
      return const Center(child: CircularProgressIndicator());
    }

    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
          3,
          (index) => Container(
            height: index == 0 ? 88 : 56,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class StaffEmptyState extends StatelessWidget {
  const StaffEmptyState({
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onRetry,
    this.retryLabel = 'Tải lại',
    super.key,
  });

  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return _StaffMessageState(
      icon: icon,
      message: message,
      action: onRetry == null
          ? null
          : OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryLabel),
            ),
    );
  }
}

class StaffErrorState extends StatelessWidget {
  const StaffErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _StaffMessageState(
      icon: Icons.error_outline,
      color: Theme.of(context).colorScheme.error,
      message: message,
      action: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Thử lại'),
      ),
    );
  }
}

class _StaffMessageState extends StatelessWidget {
  const _StaffMessageState({
    required this.icon,
    required this.message,
    this.color,
    this.action,
  });

  final IconData icon;
  final String message;
  final Color? color;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              if (action != null) ...[const SizedBox(height: 16), action!],
            ],
          ),
        ),
      ),
    );
  }
}
