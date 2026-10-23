import 'package:flutter/material.dart';

import '../widgets/titulo_secao.dart';

const List<Map<String, dynamic>> _previsaoSemana = [
  {
    'dia': 'Sexta',
    'icone': Icons.wb_sunny,
    'cor': Colors.orange,
    'minima': '19°C',
    'maxima': '30°C',
  },
  {
    'dia': 'Sábado',
    'icone': Icons.cloud,
    'cor': Colors.blueGrey,
    'minima': '18°C',
    'maxima': '27°C',
  },
  {
    'dia': 'Domingo',
    'icone': Icons.umbrella,
    'cor': Colors.indigo,
    'minima': '17°C',
    'maxima': '24°C',
  },
  {
    'dia': 'Segunda',
    'icone': Icons.cloud,
    'cor': Colors.blueGrey,
    'minima': '18°C',
    'maxima': '26°C',
  },
  {
    'dia': 'Terça',
    'icone': Icons.wb_sunny,
    'cor': Colors.orange,
    'minima': '19°C',
    'maxima': '31°C',
  },
];

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
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _previsaoSemana.length,
            itemBuilder: (context, index) {
              final dia = _previsaoSemana[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(dia['dia'] as String)),
                    Icon(
                      dia['icone'] as IconData,
                      size: 28,
                      color: dia['cor'] as Color,
                    ),
                    Expanded(child: Text(dia['minima'] as String)),
                    Expanded(child: Text(dia['maxima'] as String)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
