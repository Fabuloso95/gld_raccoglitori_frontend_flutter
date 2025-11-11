import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/raccoglitori_view_model.dart';
import 'package:gld_raccoglitori/widgets/crea_raccoglitore_dialog.dart';
import '../services/raccoglitori_api_service.dart';

class ListaRaccoglitoriScreen extends StatefulWidget 
{
  const ListaRaccoglitoriScreen({super.key});

  @override
  State<ListaRaccoglitoriScreen> createState() => _ListaRaccoglitoriScreenState();
}

class _ListaRaccoglitoriScreenState extends State<ListaRaccoglitoriScreen> 
{
  final TextEditingController _searchController = TextEditingController();
  bool _searchMode = false;

  @override
  void initState() 
  {
    super.initState();
    _caricaRaccoglitori();
  }

  void _caricaRaccoglitori() 
  {
    final viewModel = context.read<RaccoglitoriViewModel>();
    viewModel.caricaRaccoglitori();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: _searchMode ? _buildSearchField() : const Text('Raccoglitori'),
        actions: [
          if (!_searchMode) ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _searchMode = true),
              tooltip: 'Cerca',
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _mostraDialogoCreaRaccoglitore(context),
              tooltip: 'Aggiungi Raccoglitore',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _caricaRaccoglitori,
            tooltip: 'Ricarica',
          ),
        ],
      ),
      body: Consumer<RaccoglitoriViewModel>(
        builder: (context, viewModel, child) 
        {
          if (viewModel.isLoading && viewModel.raccoglitori.isEmpty) 
          {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) 
          {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Errore: ${viewModel.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () 
                    {
                      viewModel.clearError();
                      _caricaRaccoglitori();
                    },
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.raccoglitoriFiltrati.isEmpty) 
          {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Nessun raccoglitore trovato',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  Text(
                    viewModel.termineRicerca?.isNotEmpty == true
                        ? 'Prova a modificare la ricerca'
                        : 'Aggiungi il primo raccoglitore',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.raccoglitoriFiltrati.length,
            itemBuilder: (context, index) 
            {
              final raccoglitore = viewModel.raccoglitoriFiltrati[index];
              return _RaccoglitoreCard(raccoglitore: raccoglitore);
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchField() 
  {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Cerca per nome o cognome...',
        border: InputBorder.none,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () 
              {
                _searchController.clear();
                context.read<RaccoglitoriViewModel>().cercaRaccoglitori('');
                setState(() => _searchMode = false);
              },
            ),
          ],
        ),
      ),
      onChanged: (value) 
      {
        context.read<RaccoglitoriViewModel>().cercaRaccoglitori(value);
      },
      onSubmitted: (value) 
      {
        if (value.isEmpty) 
        {
          setState(() => _searchMode = false);
        }
      },
    );
  }

  void _mostraDialogoCreaRaccoglitore(BuildContext context) 
  {
    showDialog(
      context: context,
      builder: (context) => const CreaRaccoglitoreDialog(),
    );
  }
}

class _RaccoglitoreCard extends StatelessWidget 
{
  final Raccoglitore raccoglitore;

  const _RaccoglitoreCard({required this.raccoglitore});

  @override
  Widget build(BuildContext context) 
  {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            '${raccoglitore.nome[0]}${raccoglitore.cognome[0]}'.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          '${raccoglitore.nome} ${raccoglitore.cognome}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('ID: ${raccoglitore.id}'),
        trailing: IconButton(
          icon: const Icon(Icons.visibility, color: Colors.blue),
          onPressed: () => _mostraDettagliRaccoglitore(context),
        ),
        onTap: () => _mostraDettagliRaccoglitore(context),
      ),
    );
  }

  void _mostraDettagliRaccoglitore(BuildContext context) 
  {
    // TODO: Implementa schermata dettagli raccoglitore
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dettagli Raccoglitore'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: ${raccoglitore.nome}'),
            Text('Cognome: ${raccoglitore.cognome}'),
            Text('ID: ${raccoglitore.id}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }
}