import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/curiosita_view_model.dart';
import 'package:gld_raccoglitori/models/curiosita_response.dart';

class ListaCuriositaScreen extends StatefulWidget 
{
  final int libroId;
  final int? paginaRiferimento;
  final String? titoloLibro;

  const ListaCuriositaScreen({
    super.key,
    required this.libroId,
    this.paginaRiferimento,
    this.titoloLibro,
  });

  @override
  State<ListaCuriositaScreen> createState() => _ListaCuriositaScreenState();
}

class _ListaCuriositaScreenState extends State<ListaCuriositaScreen> 
{
  @override
  void initState() 
  {
    super.initState();
    _caricaCuriosita();
  }

  void _caricaCuriosita() 
  {
    final viewModel = context.read<CuriositaViewModel>();
    
    if (widget.paginaRiferimento != null) 
    {
      viewModel.caricaCuriositaPerPagina(
        libroId: widget.libroId,
        paginaRiferimento: widget.paginaRiferimento!,
      );
    } 
    else 
    {
      viewModel.caricaCuriositaPerLibro(widget.libroId);
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.titoloLibro != null
              ? 'Curiosità - ${widget.titoloLibro}'
              : widget.paginaRiferimento != null
                  ? 'Curiosità Pagina ${widget.paginaRiferimento}'
                  : 'Curiosità',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _caricaCuriosita,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _mostraDialogoAggiungiCuriosita(context);
            },
          ),
        ],
      ),
      body: Consumer<CuriositaViewModel>(
        builder: (context, viewModel, child) 
        {
          final curiosita = widget.paginaRiferimento != null
              ? viewModel.curiositaPagina
              : viewModel.curiositaLibro;

          if (viewModel.isLoading && curiosita.isEmpty) 
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
                  ),
                  ElevatedButton(
                    onPressed: () 
                    {
                      viewModel.clearError();
                      _caricaCuriosita();
                    },
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            );
          }

          if (curiosita.isEmpty) 
          {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nessuna curiosità ancora',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  Text(
                    'Sii il primo a condividere una curiosità!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: curiosita.length,
            itemBuilder: (context, index) 
            {
              final curiositaItem = curiosita[index];
              return _CuriositaCard(curiosita: curiositaItem);
            },
          );
        },
      ),
    );
  }

  void _mostraDialogoAggiungiCuriosita(BuildContext context) 
  {
    showDialog(
      context: context,
      builder: (context) => AggiungiCuriositaDialog(
        libroId: widget.libroId,
        paginaRiferimento: widget.paginaRiferimento,
      ),
    );
  }
}

// Widget per la card della curiosità
class _CuriositaCard extends StatelessWidget 
{
  final CuriositaResponse curiosita;

  const _CuriositaCard({required this.curiosita});

  @override
  Widget build(BuildContext context) 
  {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con titolo e pagina
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    curiosita.titolo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (curiosita.paginaRiferimento > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Text(
                      'Pag. ${curiosita.paginaRiferimento}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Contenuto
            Text(
              curiosita.contenuto,
              style: const TextStyle(fontSize: 14),
            ),
            
            const SizedBox(height: 8),
            
            // Footer con autore
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey.shade300,
                  child: Text(
                    curiosita.utenteCreatore.iniziale,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  curiosita.utenteCreatore.nomeVisualizzato,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                // Azioni (modifica/elimina) - da implementare se necessario
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Dialog per aggiungere una curiosità
class AggiungiCuriositaDialog extends StatefulWidget 
{
  final int libroId;
  final int? paginaRiferimento;

  const AggiungiCuriositaDialog({
    super.key,
    required this.libroId,
    this.paginaRiferimento,
  });

  @override
  State<AggiungiCuriositaDialog> createState() => _AggiungiCuriositaDialogState();
}

class _AggiungiCuriositaDialogState extends State<AggiungiCuriositaDialog> 
{
  final _formKey = GlobalKey<FormState>();
  final _titoloController = TextEditingController();
  final _contenutoController = TextEditingController();
  final _paginaController = TextEditingController();

  @override
  void initState() 
  {
    super.initState();
    if (widget.paginaRiferimento != null) 
    {
      _paginaController.text = widget.paginaRiferimento!.toString();
    }
  }

  @override
  void dispose() 
  {
    _titoloController.dispose();
    _contenutoController.dispose();
    _paginaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return AlertDialog(
      title: const Text('Aggiungi Curiosità'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titoloController,
              decoration: const InputDecoration(
                labelText: 'Titolo',
                border: OutlineInputBorder(),
              ),
              validator: (value) 
              {
                if (value == null || value.isEmpty) 
                {
                  return 'Inserisci un titolo';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contenutoController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Contenuto',
                border: OutlineInputBorder(),
              ),
              validator: (value) 
              {
                if (value == null || value.isEmpty) 
                {
                  return 'Inserisci il contenuto';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _paginaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Pagina di riferimento (opzionale)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        Consumer<CuriositaViewModel>(
          builder: (context, viewModel, child) 
          {
            return ElevatedButton(
              onPressed: viewModel.isLoading ? null : () => _aggiungiCuriosita(context),
              child: viewModel.isLoading ? const CircularProgressIndicator() : const Text('Aggiungi'),
            );
          },
        ),
      ],
    );
  }

  Future<void> _aggiungiCuriosita(BuildContext context) async 
  {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<CuriositaViewModel>();
    final navigator = Navigator.of(context);

    final success = await viewModel.creaCuriositaRapida(
      libroId: widget.libroId,
      titolo: _titoloController.text.trim(),
      contenuto: _contenutoController.text.trim(),
      paginaRiferimento: int.tryParse(_paginaController.text) ?? 0,
    );

    if (success) 
    {
      navigator.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Curiosità aggiunta con successo!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}