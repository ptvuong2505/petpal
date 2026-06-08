import 'package:flutter/material.dart';

class UserLayout extends StatelessWidget {
  const UserLayout({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}
