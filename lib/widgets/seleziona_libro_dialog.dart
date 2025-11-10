import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/libro_view_model.dart';
import 'package:gld_raccoglitori/models/libro_response.dart';

class SelezionaLibroDialog extends StatefulWidget 
{
  final Function(LibroResponse) onLibroSelezionato;
  final List<int> libriEsclusi;

  const SelezionaLibroDialog({
    super.key,
    required this.onLibroSelezionato,
    required this.libriEsclusi,
  });

  @override
  State<SelezionaLibroDialog> createState() => _SelezionaLibroDialogState();
}

class _SelezionaLibroDialogState extends State<SelezionaLibroDialog> 
{
  final TextEditingController _searchController = TextEditingController();
  List<LibroResponse> _libriFiltrati = [];

  @override
  void initState() 
  {
    super.initState();
    _caricaLibri();
  }

  void _caricaLibri() 
  {
    final viewModel = context.read<LibroViewModel>();
    if (viewModel.libri.isEmpty) 
    {
      viewModel.caricaLibri();
    }
    _filtraLibri();
  }

  void _filtraLibri() 
  {
    final viewModel = context.read<LibroViewModel>();
    final searchTerm = _searchController.text.toLowerCase();
    
    _libriFiltrati = viewModel.libri.where((libro) 
    {
      final matchesSearch = searchTerm.isEmpty ||
          libro.titolo.toLowerCase().contains(searchTerm) ||
          libro.autore.toLowerCase().contains(searchTerm);
      
      final nonEscluso = !widget.libriEsclusi.contains(libro.id);
      
      return matchesSearch && nonEscluso;
    }).toList();
    
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) 
  {
    return Dialog(
      child: Consumer<LibroViewModel>(
        builder: (context, viewModel, child) 
        {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Seleziona Libro da Proporre',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                
                // Barra di ricerca
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Cerca per titolo o autore...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _filtraLibri(),
                ),
                const SizedBox(height: 16),
                
                // Lista libri
                if (viewModel.isLoading && _libriFiltrati.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  )
                else if (_libriFiltrati.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'Nessun libro disponibile',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: _libriFiltrati.length,
                      itemBuilder: (context, index) {
                        final libro = _libriFiltrati[index];
                        return _LibroListItem(
                          libro: libro,
                          onTap: () {
                            widget.onLibroSelezionato(libro);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Bottone annulla
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annulla'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() 
  {
    _searchController.dispose();
    super.dispose();
  }
}

class _LibroListItem extends StatelessWidget 
{
  final LibroResponse libro;
  final VoidCallback onTap;

  const _LibroListItem({
    required this.libro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) 
  {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            image: libro.copertinaUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(libro.copertinaUrl),
                    fit: BoxFit.cover,
                  )
                : null,
            color: libro.copertinaUrl.isEmpty ? Colors.grey[200] : null,
          ),
          child: libro.copertinaUrl.isEmpty ? const Icon(Icons.book, size: 20, color: Colors.grey) : null),
        title: Text(
          libro.titolo,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          libro.autore,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}