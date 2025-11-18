import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/libro_view_model.dart';
import 'package:gld_raccoglitori/models/libro_response.dart';
import 'package:gld_raccoglitori/view_models/lettura_corrente_view_model.dart';

class ListaLibriScreen extends StatefulWidget 
{
  final bool? mostraSoloNonLetti;

  const ListaLibriScreen({
    super.key,
    this.mostraSoloNonLetti,
  });

  @override
  State<ListaLibriScreen> createState() => _ListaLibriScreenState();
}

class _ListaLibriScreenState extends State<ListaLibriScreen> 
{
  final TextEditingController _searchController = TextEditingController();
  bool _searchMode = false;

  @override
  void initState() 
  {
    super.initState();
    _caricaLibri();
  }

  void _caricaLibri() 
  {
    final viewModel = context.read<LibroViewModel>();
    viewModel.caricaLibri();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
      title: _searchMode ? _buildSearchField() : Text(widget.mostraSoloNonLetti == true ? 'Libri da Leggere' : 'Biblioteca',
                                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                                      ),
      actions: [
        if (!_searchMode) ...[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => _searchMode = true),
            tooltip: 'Cerca libri',
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: FloatingActionButton(
              onPressed: () => _mostraDialogoCreaLibro(context),
              tooltip: 'Aggiungi Nuovo Libro',
              mini: true,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _caricaLibri,
          tooltip: 'Ricarica lista',
        ),
      ],
    ),
      body: Consumer<LibroViewModel>(
        builder: (context, viewModel, child) 
        {
          List<LibroResponse> libriDaMostrare = widget.mostraSoloNonLetti == true ? viewModel.libriNonLetti : viewModel.libriFiltrati;

          if (viewModel.isLoading && libriDaMostrare.isEmpty) 
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
                      _caricaLibri();
                    },
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            );
          }

          if (libriDaMostrare.isEmpty) 
          {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.menu_book, size: 80, color: Colors.grey),
                    const SizedBox(height: 20),
                    Text(
                      widget.mostraSoloNonLetti == true
                          ? 'Nessun libro da leggere'
                          : 'La biblioteca è vuota',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.mostraSoloNonLetti == true
                          ? 'Tutti i libri sono stati letti!'
                          : 'Aggiungi il primo libro alla biblioteca',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () => _mostraDialogoCreaLibro(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Aggiungi Primo Libro'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.mostraSoloNonLetti == true)
                      TextButton(
                        onPressed: ()
                        {
                          Navigator.pushReplacementNamed(context, '/libri');
                        },
                        child: const Text('Vedi Tutti i Libri'),
                      ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.6,
            ),
            itemCount: libriDaMostrare.length,
            itemBuilder: (context, index) {
              final libro = libriDaMostrare[index];
              return _LibroCard(libro: libro);
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
        hintText: 'Cerca per titolo, autore...',
        border: InputBorder.none,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                context.read<LibroViewModel>().filtraLibriLocalmente('');
                setState(() => _searchMode = false);
              },
            ),
          ],
        ),
      ),
      onChanged: (value) 
      {
        context.read<LibroViewModel>().filtraLibriLocalmente(value);
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

  void _mostraDialogoCreaLibro(BuildContext context) 
  {
    Navigator.pushNamed(context, '/crea-libro');
  }
}

class _LibroCard extends StatelessWidget 
{
  final LibroResponse libro;

  const _LibroCard({required this.libro});

  @override
  Widget build(BuildContext context) 
  {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _navigaADettaglioLibro(context),
        onLongPress: () => _mostraMenuContestuale(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // COPERTINA
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  image: libro.copertinaUrl.isNotEmpty ? DecorationImage(image: NetworkImage(libro.copertinaUrl), fit: BoxFit.cover) : null,
                  color: libro.copertinaUrl.isEmpty ? Colors.grey[200] : null,
                ),
                child: libro.copertinaUrl.isEmpty ? const Icon(Icons.book, size: 40, color: Colors.grey) : null,
              ),
            ),
            
            // INFO LIBRO
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      libro.titolo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      libro.autore,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          libro.annoPubblicazione.toString(),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        if (libro.letto)
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigaADettaglioLibro(BuildContext context) 
  {
    Navigator.pushNamed(
      context,
      '/dettaglio-libro',
      arguments: {
        'libroId': libro.id,
      },
    );
  }

  void _mostraMenuContestuale(BuildContext context) 
  {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.visibility),
            title: const Text('Vedi Dettagli'),
            onTap: () 
            {
              Navigator.pop(context);
              _navigaADettaglioLibro(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Inizia a Leggere'),
            onTap: () 
            {
              Navigator.pop(context);
              _iniziaLettura(context);
            },
          ),
          if (context.read<LibroViewModel>().libroSelezionato != null)
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifica'),
              onTap: () 
              {
                Navigator.pop(context);
                // TODO: Implementa modifica libro
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Elimina', style: TextStyle(color: Colors.red)),
            onTap: () 
            {
              Navigator.pop(context);
              _eliminaLibro(context);
            },
          ),
        ],
      ),
    );
  }

  void _iniziaLettura(BuildContext context) 
  {
    final letturaViewModel = context.read<LetturaCorrenteViewModel>();
    
    // Verifica se esiste già una lettura per questo libro
    final letturaEsistente = letturaViewModel.getLetturaPerLibro(libro.id);
    
    if (letturaEsistente != null) 
    {
      // Naviga alla lettura esistente
      Navigator.pushNamed(
        context,
        '/lettura',
        arguments: {
          'bookId': libro.id,
          'bookTitle': libro.titolo,
          'numeroPagineTotali': libro.numeroPagine,
        },
      );
    } 
    else 
    {
      // Inizia una nuova lettura
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Inizia Lettura'),
          content: Text('Vuoi iniziare a leggere "${libro.titolo}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () async 
              {
                Navigator.pop(context);
                final success = await letturaViewModel.iniziaLettura(
                  libroId: libro.id,
                  paginaIniziale: 1,
                );
                
                if (success) 
                {
                  Navigator.pushNamed(
                    context,
                    '/lettura',
                    arguments: 
                    {
                      'bookId': libro.id,
                      'bookTitle': libro.titolo,
                      'numeroPagineTotali': libro.numeroPagine,
                    },
                  );
                }
              },
              child: const Text('Inizia'),
            ),
          ],
        ),
      );
    }
  }

  void _eliminaLibro(BuildContext context) 
  {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Libro'),
        content: Text('Sei sicuro di voler eliminare "${libro.titolo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () 
            {
              context.read<LibroViewModel>().eliminaLibro(libro.id);
              Navigator.pop(context);
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