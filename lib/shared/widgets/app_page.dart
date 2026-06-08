import 'package:flutter/material.dart';

import '../../core/services/navigation_service.dart';
import 'app_button.dart';

class PageAction {
  const PageAction({required this.label, required this.routeName});

  final String label;
  final String routeName;
}

class AppPage extends StatelessWidget {
  const AppPage({
    required this.title,
    required this.message,
    this.actions = const [],
    this.onAction,
    super.key,
  });

  final String title;
  final String message;
  final List<PageAction> actions;
  final ValueChanged<String>? onAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                for (final action in actions) ...[
                  AppButton(
                    label: action.label,
                    onPressed: () => _open(context, action.routeName),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, String routeName) {
    final handler = onAction;
    if (handler != null) {
      handler(routeName);
      return;
    }

    NavigationService.goTo(context, routeName);
  }
}
