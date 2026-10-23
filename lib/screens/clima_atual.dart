import 'package:flutter/material.dart';

import '../widgets/titulo_secao.dart';

class ClimaAtualScreen extends StatelessWidget {
  const ClimaAtualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima atual'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TituloSecao(titulo: 'Cidade atual'),
          Container(
            color: Colors.lightBlue.shade100,
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Santo André',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Quinta-feira, 15 de outubro',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          const TituloSecao(titulo: 'Temperatura'),
          const Center(
            child: Column(
              children: [
                Text(
                  '26°C',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Sensação térmica: 28°C',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(),
          const TituloSecao(titulo: 'Condição do tempo'),
          Image.network(
            'https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8f/Pa%C3%A7o_Municipal_de_Santo_Andr%C3%A9_-_SP.jpg/960px-Pa%C3%A7o_Municipal_de_Santo_Andr%C3%A9_-_SP.jpg',
            height: 200,
            fit: BoxFit.cover,
          ),
          const Divider(),
          const TituloSecao(titulo: 'Detalhes'),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.water_drop, color: Colors.blue, size: 32),
              Icon(Icons.air, color: Colors.teal, size: 32),
              Icon(Icons.umbrella, color: Colors.indigo, size: 32),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('65%', style: TextStyle(fontSize: 16)),
                Text('12 km/h', style: TextStyle(fontSize: 16)),
                Text('30%', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const Divider(),
          const TituloSecao(titulo: 'Atualização'),
          Center(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dados atualizados!')),
                );
              },
              child: const Text('Atualizar'),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 80,
            color: Colors.grey.shade200,
            child: const Align(
              alignment: Alignment.bottomRight,
              child: Text('Última atualização: 14:30'),
            ),
          ),
        ],
      ),
    );
  }
}
