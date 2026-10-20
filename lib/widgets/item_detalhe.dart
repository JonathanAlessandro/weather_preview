import 'package:flutter/material.dart';

class ItemDetalhe extends StatelessWidget {
  const ItemDetalhe({
    super.key,
    required this.icone,
    required this.cor,
    required this.valor,
  });

  final IconData icone;
  final Color cor;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icone, color: cor, size: 32),
        const SizedBox(height: 8),
        Text(valor, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
