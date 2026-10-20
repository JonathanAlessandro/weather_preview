import 'package:flutter/material.dart';

class TituloSecao extends StatelessWidget {
  const TituloSecao({super.key, required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
