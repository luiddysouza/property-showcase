import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/design/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Property Showcase',
      theme: AppTheme.light(),
      home: Scaffold(
        appBar: AppBar(title: const Text('Property Showcase')),
        body: const Center(child: Text('Coming soon...')),
      ),
    );
  }
}
