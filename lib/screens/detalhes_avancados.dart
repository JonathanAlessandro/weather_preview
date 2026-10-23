import 'package:flutter/material.dart';

import '../widgets/titulo_secao.dart';

class DetalhesAvancadosScreen extends StatelessWidget {
  const DetalhesAvancadosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes avançados'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TituloSecao(titulo: 'Alertas'),
          const Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.warning, color: Colors.orange),
              title: Text('Chuva forte'),
              subtitle: Text('Previsto para hoje, a partir das 18h'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.storm, color: Colors.blueGrey),
              title: Text('Vento forte'),
              subtitle: Text('Rajadas de até 60 km/h no fim da tarde'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          const Divider(),
          const TituloSecao(titulo: 'Indicadores'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: const [
              Card(
                elevation: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wb_sunny, size: 32, color: Colors.orange),
                    SizedBox(height: 8),
                    Text(
                      '6',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Índice UV'),
                  ],
                ),
              ),
              Card(
                elevation: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.speed, size: 32, color: Colors.blue),
                    SizedBox(height: 8),
                    Text(
                      '1012 hPa',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Pressão'),
                  ],
                ),
              ),
              Card(
                elevation: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility, size: 32, color: Colors.teal),
                    SizedBox(height: 8),
                    Text(
                      '10 km',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Visibilidade'),
                  ],
                ),
              ),
              Card(
                elevation: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wb_twilight, size: 32, color: Colors.deepOrange),
                    SizedBox(height: 8),
                    Text(
                      '06:12',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Nascer do sol'),
                  ],
                ),
              ),
            ],
          ),
          const Divider(),
          const TituloSecao(titulo: 'Condição do tempo'),
          Stack(
            children: [
              Image.network(
                'https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8f/Pa%C3%A7o_Municipal_de_Santo_Andr%C3%A9_-_SP.jpg/960px-Pa%C3%A7o_Municipal_de_Santo_Andr%C3%A9_-_SP.jpg',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const Positioned(
                left: 16,
                bottom: 16,
                child: Text(
                  '26°C',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Positioned(
                top: 16,
                right: 16,
                child: Icon(Icons.wb_sunny, color: Colors.white, size: 32),
              ),
            ],
          ),
          const Divider(),
          const TituloSecao(titulo: 'Tags'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              Chip(
                avatar: Icon(Icons.water_drop, size: 18, color: Colors.blue),
                label: Text('Chuva forte'),
              ),
              Chip(label: Text('UV alto')),
              Chip(
                avatar: Icon(Icons.air, size: 18, color: Colors.teal),
                label: Text('Vento moderado'),
              ),
              Chip(label: Text('Umidade alta')),
              Chip(label: Text('Frente fria')),
            ],
          ),
        ],
      ),
    );
  }
}
