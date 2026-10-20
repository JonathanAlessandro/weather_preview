import 'package:flutter/material.dart';

import '../location_search_service.dart';
import '../location_service.dart';

class LocationSearchDialog extends StatefulWidget {
  const LocationSearchDialog({super.key, required this.service});

  final LocationSearchService service;

  @override
  State<LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
  final _query = TextEditingController();
  List<WeatherLocation> _results = [];
  bool _loading = false;
  bool _searched = false;
  String? _error;
  int _request = 0;

  Future<void> _search() async {
    final query = _query.text.trim();
    if (query.length < 2) {
      setState(() => _error = 'Digite pelo menos 2 caracteres.');
      return;
    }
    final request = ++_request;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _searched = false;
      _results = [];
      _error = null;
    });
    try {
      final results = await widget.service.search(query);
      if (!mounted || request != _request) return;
      setState(() {
        _results = results;
        _searched = true;
      });
    } catch (_) {
      if (!mounted || request != _request) return;
      setState(() => _error = 'Não foi possível pesquisar. Verifique sua conexão e tente novamente.');
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  const Expanded(child: Text('Pesquisar cidade',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  IconButton(tooltip: 'Fechar', onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close)),
                ]),
                TextField(
                  controller: _query,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(labelText: 'Nome da cidade',
                      hintText: 'Ex.: Campinas', border: OutlineInputBorder()),
                  onSubmitted: (_) { if (!_loading) _search(); },
                  onChanged: (_) {
                    // Uma resposta antiga não pode substituir a pesquisa atual.
                    setState(() {
                      _request++;
                      _loading = false;
                      _searched = false;
                      _results = [];
                      _error = null;
                    });
                  },
                ),
                const SizedBox(height: 8),
                FilledButton.icon(onPressed: _loading ? null : _search,
                    icon: const Icon(Icons.search), label: const Text('Buscar')),
                if (_loading) const LinearProgressIndicator(),
                if (_error != null)
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                if (_searched && _results.isEmpty)
                  const Text('Nenhuma cidade encontrada. Tente outro nome.'),
                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final location = _results[index];
                      return ListTile(
                        leading: const Icon(Icons.location_city),
                        title: Text(location.label),
                        onTap: () => Navigator.pop(context, location),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
