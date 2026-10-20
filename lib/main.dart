import 'package:flutter/material.dart';

import 'widgets/item_detalhe.dart';
import 'widgets/titulo_secao.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('WeatherApp'),
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const TituloSecao(titulo: 'Cidade atual'),
            const Text(
              'Santo André',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Quinta-feira, 15 de outubro',
              style: TextStyle(fontSize: 16),
            ),
            const Divider(),
            const TituloSecao(titulo: 'Temperatura'),
            const Text(
              '26°C',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const Text(
              'Sensação térmica: 28°C',
              style: TextStyle(fontSize: 16),
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
                ItemDetalhe(
                  icone: Icons.water_drop,
                  cor: Colors.blue,
                  valor: '65%',
                ),
                ItemDetalhe(
                  icone: Icons.air,
                  cor: Colors.teal,
                  valor: '12 km/h',
                ),
                ItemDetalhe(
                  icone: Icons.umbrella,
                  cor: Colors.indigo,
                  valor: '30%',
                ),
              ],
            ),
            const Divider(),
            const TituloSecao(titulo: 'Atualização'),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Atualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
