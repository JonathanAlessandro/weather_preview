import 'package:flutter/material.dart';

import '../widgets/titulo_secao.dart';

class PrevisaoSemanaScreen extends StatelessWidget {
  const PrevisaoSemanaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previsão da semana'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TituloSecao(titulo: 'Faixa de temperatura'),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 60,
                  color: Colors.lightBlue.shade100,
                  child: const Center(child: Text('18°C')),
                ),
              ),
              Flexible(
                flex: 2,
                child: Container(
                  height: 60,
                  color: Colors.orange.shade200,
                  child: const Center(child: Text('26°C')),
                ),
              ),
              Expanded(
                child: Container(
                  height: 60,
                  color: Colors.red.shade200,
                  child: const Center(child: Text('31°C')),
                ),
              ),
            ],
          ),
          const Divider(),
          const TituloSecao(titulo: 'Resumo do dia'),
          Container(
            height: 200,
            color: Colors.grey.shade200,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.lightBlue.shade100,
                    child: const Center(child: Text('Manhã: 20°C')),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                    color: Colors.orange.shade200,
                    child: const Center(child: Text('Tarde: 29°C')),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          const TituloSecao(titulo: 'Próximos dias'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('Sexta')),
                Icon(Icons.wb_sunny, size: 28, color: Colors.orange),
                Expanded(child: Text('19°C')),
                Expanded(child: Text('30°C')),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('Sábado')),
                Icon(Icons.cloud, size: 28, color: Colors.blueGrey),
                Expanded(child: Text('18°C')),
                Expanded(child: Text('27°C')),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('Domingo')),
                Icon(Icons.umbrella, size: 28, color: Colors.indigo),
                Expanded(child: Text('17°C')),
                Expanded(child: Text('24°C')),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('Segunda')),
                Icon(Icons.cloud, size: 28, color: Colors.blueGrey),
                Expanded(child: Text('18°C')),
                Expanded(child: Text('26°C')),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text('Terça')),
                Icon(Icons.wb_sunny, size: 28, color: Colors.orange),
                Expanded(child: Text('19°C')),
                Expanded(child: Text('31°C')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
