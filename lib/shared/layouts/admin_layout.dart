import 'package:flutter/material.dart';

class AdminLayout extends StatelessWidget {
  const AdminLayout({required this.title, required this.child, super.key});

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
