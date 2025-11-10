import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/frase_preferita_view_model.dart';
import 'package:gld_raccoglitori/models/frase_preferita_response.dart';

class ListaFrasiPreferiteScreen extends StatefulWidget 
{
  final int? libroId;
  final String? titoloLibro;

  const ListaFrasiPreferiteScreen({
    super.key,
    this.libroId,
    this.titoloLibro,
  });

  @override
  State<ListaFrasiPreferiteScreen> createState() => _ListaFrasiPreferiteScreenState();
}

class _ListaFrasiPreferiteScreenState extends State<ListaFrasiPreferiteScreen> 
{
  @override
  void initState() 
  {
    super.initState();
    _caricaFrasi();
  }

  void _caricaFrasi() 
  {
    final viewModel = context.read<FrasePreferitaViewModel>();
    
    if (widget.libroId != null) 
    {
      viewModel.caricaFrasiPerLibro(widget.libroId!);
    } 
    else 
    {
      viewModel.caricaMieFrasiPreferite();
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.titoloLibro != null
              ? 'Frasi Preferite - ${widget.titoloLibro}'
              : 'Le Mie Frasi Preferite',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _caricaFrasi,
          ),
        ],
      ),
      body: Consumer<FrasePreferitaViewModel>(
        builder: (context, viewModel, child) {
          final frasi = widget.libroId != null ? viewModel.frasiLibro : viewModel.mieFrasi;

          if (viewModel.isLoading && frasi.isEmpty) 
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
                      _caricaFrasi();
                    },
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            );
          }

          if (frasi.isEmpty) 
          {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.format_quote, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nessuna frase preferita ancora',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  Text(
                    'Salva le frasi che più ti colpiscono!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: frasi.length,
            itemBuilder: (context, index) 
            {
              final frase = frasi[index];
              return _FrasePreferitaCard(frase: frase);
            },
          );
        },
      ),
    );
  }
}

// Widget per la card della frase preferita
class _FrasePreferitaCard extends StatelessWidget 
{
  final FrasePreferitaResponse frase;

  const _FrasePreferitaCard({required this.frase});

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
            // Testo della frase
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.format_quote, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    frase.testoFrase,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Info libro e pagina
            Row(
              children: [
                if (frase.paginaRiferimento > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Text(
                      'Pag. ${frase.paginaRiferimento}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => _eliminaFrase(context, frase.id),
                  color: Colors.grey,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _eliminaFrase(BuildContext context, int fraseId) 
  {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina frase'),
        content: const Text('Sei sicuro di voler eliminare questa frase preferita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () 
            {
              context.read<FrasePreferitaViewModel>().eliminaFrasePreferita(fraseId);
              Navigator.of(context).pop();
            },
            child: const Text(
              'Elimina',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}