import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/libro_view_model.dart';
import 'package:gld_raccoglitori/view_models/lettura_corrente_view_model.dart';
import 'package:gld_raccoglitori/view_models/frase_preferita_view_model.dart';
import 'package:gld_raccoglitori/view_models/curiosita_view_model.dart';
import 'package:gld_raccoglitori/models/libro_response.dart';
import 'package:gld_raccoglitori/widgets/crea_libro_dialog.dart';
import '../widgets/aggiungi_frase_preferita_dialog.dart';
import 'package:gld_raccoglitori/widgets/aggiungi_curiosita_dialog.dart';

class DettaglioLibroScreen extends StatefulWidget {
  final int libroId;

  const DettaglioLibroScreen({
    super.key,
    required this.libroId,
  });

  @override
  State<DettaglioLibroScreen> createState() => _DettaglioLibroScreenState();
}

class _DettaglioLibroScreenState extends State<DettaglioLibroScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _caricaDettagliLibro();
  }

  Future<void> _caricaDettagliLibro() async {
    final libroViewModel = context.read<LibroViewModel>();
    final fraseViewModel = context.read<FrasePreferitaViewModel>();
    final curiositaViewModel = context.read<CuriositaViewModel>();

    try {
      // Carica dettagli libro
      await libroViewModel.caricaLibroPerId(widget.libroId);
      
      // Carica frasi preferite per questo libro
      await fraseViewModel.caricaFrasiPerLibro(widget.libroId);
      
      // Carica curiosità per questo libro
      await curiositaViewModel.caricaCuriositaPerLibro(widget.libroId);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio Libro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _modificaLibro(context),
            tooltip: 'Modifica Libro',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _caricaDettagliLibro,
            tooltip: 'Ricarica',
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _gestisciMenuAction(value, context),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'inizia_lettura',
                child: ListTile(
                  leading: Icon(Icons.play_arrow),
                  title: Text('Inizia Lettura'),
                ),
              ),
              const PopupMenuItem(
                value: 'condividi',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Condividi'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'elimina',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Elimina', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Info'),
            Tab(icon: Icon(Icons.format_quote), text: 'Frasi'),
            Tab(icon: Icon(Icons.emoji_objects), text: 'Curiosità'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<LibroViewModel>(
              builder: (context, libroViewModel, child) {
                final libro = libroViewModel.libroSelezionato;
                
                if (libro == null) {
                  return _buildErroreSchermata('Libro non trovato');
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInfoTab(libro),
                    _buildFrasiTab(libro),
                    _buildCuriositaTab(libro),
                  ],
                );
              },
            ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildInfoTab(LibroResponse libro) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Copertina e titolo
          Center(
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: libro.copertinaUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(libro.copertinaUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: libro.copertinaUrl.isEmpty ? Colors.grey[200] : null,
                  ),
                  child: libro.copertinaUrl.isEmpty
                      ? const Icon(Icons.book, size: 60, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  libro.titolo,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'di ${libro.autore}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Informazioni libro
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informazioni Libro',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Anno di pubblicazione', libro.annoPubblicazione.toString()),
                  _buildInfoRow('Numero di pagine', '${libro.numeroPagine} pagine'),
                  _buildInfoRow('Stato', libro.letto ? 'Letto' : 'Da leggere'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Sinossi
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sinossi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    libro.sinossi.isNotEmpty ? libro.sinossi : 'Nessuna sinossi disponibile',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Azioni rapide
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Azioni Rapide',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('Inizia Lettura'),
                        onPressed: () => _iniziaLettura(context),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.format_quote, size: 18),
                        label: const Text('Aggiungi Frase'),
                        onPressed: () => _aggiungiFrasePreferita(context),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.emoji_objects, size: 18),
                        label: const Text('Aggiungi Curiosità'),
                        onPressed: () => _aggiungiCuriosita(context),
                      ),
                      if (libro.letto)
                        ActionChip(
                          avatar: const Icon(Icons.rate_review, size: 18),
                          label: const Text('Lascia Recensione'),
                          onPressed: () => _lasciaRecensione(context),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrasiTab(LibroResponse libro) {
    return Consumer<FrasePreferitaViewModel>(
      builder: (context, fraseViewModel, child) {
        final frasi = fraseViewModel.frasiPerLibro[libro.id] ?? [];

        if (frasi.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.format_quote, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Nessuna frase preferita',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aggiungi la tua prima frase da "${libro.titolo}"',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _aggiungiFrasePreferita(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Aggiungi Frase'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${frasi.length} frasi preferite',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _aggiungiFrasePreferita(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Aggiungi'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: frasi.length,
                itemBuilder: (context, index) {
                  final frase = frasi[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(Icons.format_quote, color: Colors.blue),
                      title: Text(
                        frase.testoFrase,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      subtitle: Text('Pagina ${frase.paginaRiferimento}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminaFrasePreferita(context, frase.id),
                      ),
                      onTap: () => _mostraDettaglioFrase(context, frase),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCuriositaTab(LibroResponse libro) {
    return Consumer<CuriositaViewModel>(
      builder: (context, curiositaViewModel, child) {
        final curiositaList = curiositaViewModel.curiositaPerLibro[libro.id] ?? [];

        if (curiositaList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_objects, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Nessuna curiosità',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aggiungi la prima curiosità su "${libro.titolo}"',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _aggiungiCuriosita(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Aggiungi Curiosità'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${curiositaList.length} curiosità',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _aggiungiCuriosita(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Aggiungi'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: curiositaList.length,
                itemBuilder: (context, index) {
                  final curiosita = curiositaList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(Icons.emoji_objects, color: Colors.orange),
                      title: Text(
                        curiosita.titolo,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(curiosita.contenuto),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Pagina ${curiosita.paginaRiferimento}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminaCuriosita(context, curiosita.id),
                      ),
                      onTap: () => _mostraDettaglioCuriosita(context, curiosita),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Consumer<LibroViewModel>(
      builder: (context, libroViewModel, child) {
        final libro = libroViewModel.libroSelezionato;
        if (libro == null) return const SizedBox();

        return FloatingActionButton(
          onPressed: () => _iniziaLettura(context),
          tooltip: 'Inizia Lettura',
          child: const Icon(Icons.play_arrow),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildErroreSchermata(String messaggio) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            messaggio,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _caricaDettagliLibro,
            child: const Text('Riprova'),
          ),
        ],
      ),
    );
  }

  // Metodi per le azioni
  void _gestisciMenuAction(String value, BuildContext context) {
    switch (value) {
      case 'inizia_lettura':
        _iniziaLettura(context);
        break;
      case 'condividi':
        _condividiLibro(context);
        break;
      case 'elimina':
        _eliminaLibro(context);
        break;
    }
  }

  void _iniziaLettura(BuildContext context) {
    final libroViewModel = context.read<LibroViewModel>();
    final letturaViewModel = context.read<LetturaCorrenteViewModel>();
    final libro = libroViewModel.libroSelezionato;

    if (libro == null) return;

    final letturaEsistente = letturaViewModel.getLetturaPerLibro(libro.id);

    if (letturaEsistente != null) {
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
    } else {
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
              onPressed: () async {
                Navigator.pop(context);
                final success = await letturaViewModel.iniziaLettura(
                  libroId: libro.id,
                  paginaIniziale: 1,
                );

                if (success && mounted) {
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
              },
              child: const Text('Inizia'),
            ),
          ],
        ),
      );
    }
  }

  void _modificaLibro(BuildContext context) 
  {
  final libroViewModel = context.read<LibroViewModel>();
  final libro = libroViewModel.libroSelezionato;

  if (libro != null) 
  {
    showDialog(
      context: context,
      builder: (context) => CreaLibroDialog(
      ),
    );
  }
}

  void _aggiungiFrasePreferita(BuildContext context) {
    final libroViewModel = context.read<LibroViewModel>();
    final libro = libroViewModel.libroSelezionato;

    if (libro != null) {
      showDialog(
        context: context,
        builder: (context) => AggiungiFrasePreferitaDialog(
          libroId: libro.id,
          numeroPagineTotali: libro.numeroPagine,
        ),
      );
    }
  }

  void _aggiungiCuriosita(BuildContext context) {
  final libroViewModel = context.read<LibroViewModel>();
  final libro = libroViewModel.libroSelezionato;

  if (libro != null) {
    showDialog(
      context: context, 
      builder: (context) => AggiungiCuriositaDialog(
        libroId: libro.id,
        numeroPagineTotali: libro.numeroPagine,
      ),
    );
  }
}

  void _lasciaRecensione(BuildContext context) {
    // TODO: Implementa la funzionalità di recensione
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funzionalità recensione in sviluppo')),
    );
  }

  void _condividiLibro(BuildContext context) {
    final libroViewModel = context.read<LibroViewModel>();
    final libro = libroViewModel.libroSelezionato;

    if (libro != null) {
      // TODO: Implementa la condivisione
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Condividi "${libro.titolo}"')),
      );
    }
  }

  void _eliminaLibro(BuildContext context) {
    final libroViewModel = context.read<LibroViewModel>();
    final libro = libroViewModel.libroSelezionato;

    if (libro != null) {
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
              onPressed: () {
                libroViewModel.eliminaLibro(libro.id);
                Navigator.pop(context);
                Navigator.pop(context); // Torna indietro alla lista libri
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

  void _eliminaFrasePreferita(BuildContext context, int fraseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Frase'),
        content: const Text('Sei sicuro di voler eliminare questa frase?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              context.read<FrasePreferitaViewModel>().eliminaFrasePreferita(fraseId);
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

  void _eliminaCuriosita(BuildContext context, int curiositaId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Curiosità'),
        content: const Text('Sei sicuro di voler eliminare questa curiosità?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              context.read<CuriositaViewModel>().eliminaCuriosita(curiositaId);
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

  void _mostraDettaglioFrase(BuildContext context, dynamic frase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Frase Preferita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              frase.testo,
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
            ),
            if (frase.paginaRiferimento != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Pagina: ${frase.paginaRiferimento}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
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

  void _mostraDettaglioCuriosita(BuildContext context, dynamic curiosita) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(curiosita.titolo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(curiosita.descrizione),
            if (curiosita.paginaRiferimento != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Pagina: ${curiosita.paginaRiferimento}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
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