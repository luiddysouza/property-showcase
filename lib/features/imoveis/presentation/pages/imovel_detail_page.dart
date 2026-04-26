import 'package:flutter/material.dart';

class ImovelDetailPage extends StatelessWidget {
  final String imovelId;

  const ImovelDetailPage({
    super.key,
    required this.imovelId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Imovel Detail: $imovelId')),
    );
  }
}
