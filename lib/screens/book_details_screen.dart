import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/FrasePreferitaRequestModel.dart';
import '../models/LetturaCorrenteRequestModel.dart';
import '../services/auth_service.dart';
import '../services/libro_api_service.dart';
import '../services/lettura_corrente_api_service.dart';
import '../services/curiosita_api_service.dart';
import '../services/frase_preferita_api_service.dart';
import '../models/libro_response.dart';
import '../models/lettura_corrente_response.dart';
import '../models/curiosita_response.dart';
import '../models/frase_preferita_response.dart';

class BookDetailsScreen extends StatefulWidget 
{
  final int bookId;

  const BookDetailsScreen({super.key, required this.bookId});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  late Future<LibroResponse> _libroFuture;
  late Future<LetturaCorrenteResponse?> _letturaCorrenteFuture;
  late Future<List<CuriositaResponse>> _curiositaFuture;
  late Future<List<FrasePreferitaResponse>> _frasiFuture;
  
  int _paginaCorrenteUtente = 0;
  bool _sinossiEspansa = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBookData();
  }

  void _loadBookData() {
    final libroService = Provider.of<LibroApiService>(context, listen: false);
    final letturaService = Provider.of<LetturaCorrenteApiService>(context, listen: false);
    final curiositaService = Provider.of<CuriositaApiService>(context, listen: false);
    final frasiService = Provider.of<FrasePreferitaApiService>(context, listen: false);

    _libroFuture = libroService.getLibroById(widget.bookId);
    _letturaCorrenteFuture = _getLetturaCorrente(letturaService);
    _curiositaFuture = curiositaService.getCuriositaByLibro(libroId: widget.bookId);
    _frasiFuture = frasiService.getFrasiByLibro(libroId: widget.bookId);
  }

  Future<LetturaCorrenteResponse?> _getLetturaCorrente(LetturaCorrenteApiService service) async {
    try {
      final letture = await service.getMyReadings();
      final letturaLibro = letture.where((l) => l.libroId == widget.bookId).firstOrNull;
      
      if (letturaLibro != null) {
        _paginaCorrenteUtente = letturaLibro.paginaCorrente;
      }
      
      return letturaLibro;
    } catch (e) {
      print('Errore caricamento lettura: $e');
      return null;
    }
  }

  void _iniziaLettura() async {
    try {
      final letturaService = Provider.of<LetturaCorrenteApiService>(context, listen: false);
      final request = LetturaCorrenteRequestModel(
        libroId: widget.bookId,
        paginaIniziale: 1,
      );
      
      await letturaService.startReading(request);
      setState(() {
        _loadBookData(); // Ricarica i dati
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lettura iniziata!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _salvaFrasePreferita(String testoFrase, int pagina) async {
    try {
      final frasiService = Provider.of<FrasePreferitaApiService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final request = FrasePreferitaRequestModel(
        utenteId: authService.currentUserId!,
        libroId: widget.bookId,
        testoFrase: testoFrase,
        paginaRiferimento: pagina,
      );
      
      await frasiService.saveFrase(request);
      setState(() {
        _frasiFuture = frasiService.getFrasiByLibro(libroId: widget.bookId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Frase salvata!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettagli Libro'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Info'),
            Tab(icon: Icon(Icons.auto_stories), text: 'Curiosità'),
            Tab(icon: Icon(Icons.chat), text: 'Commenti'),
            Tab(icon: Icon(Icons.format_quote), text: 'Frasi'),
          ],
        ),
      ),
      
      body: FutureBuilder<LibroResponse>(
        future: _libroFuture,
        builder: (context, libroSnapshot) {
          if (libroSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (libroSnapshot.hasError) {
            return Center(child: Text('Errore: ${libroSnapshot.error}'));
          }
          
          if (!libroSnapshot.hasData) {
            return const Center(child: Text('Libro non trovato'));
          }
          
          final libro = libroSnapshot.data!;
          
          return TabBarView(
            controller: _tabController,
            children: [
              // 📖 TAB INFO LIBRO
              _buildInfoTab(libro),
              
              // 🔍 TAB CURIOSITÀ
              _buildCuriositaTab(libro),
              
              // 💬 TAB COMMENTI
              _buildCommentiTab(libro),
              
              // 💝 TAB FRASI
              _buildFrasiTab(libro),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoTab(LibroResponse libro) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📖 HEADER LIBRO
          _buildLibroHeader(libro),
          const SizedBox(height: 24),
          
          // 🎯 AZIONI PRINCIPALI
          _buildAzioniPrincipali(libro),
          const SizedBox(height: 24),
          
          // 📊 SINOSSI
          _buildSinossiSection(libro),
          const SizedBox(height: 24),
          
          // 📈 STATISTICHE BASE
          _buildStatisticheSection(libro),
        ],
      ),
    );
  }

  Widget _buildLibroHeader(LibroResponse libro) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // COPERTINA
        Container(
          width: 120,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: libro.copertinaUrl.isNotEmpty
                ? Image.network(
                    libro.copertinaUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.book, size: 50, color: Colors.grey),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.book, size: 50, color: Colors.grey),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        
        // INFO LIBRO
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                libro.titolo,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'di ${libro.autore}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${libro.annoPubblicazione}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.menu_book, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${libro.numeroPagine} pagine',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (libro.letto)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    'LETTO',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAzioniPrincipali(LibroResponse libro) {
    return FutureBuilder<LetturaCorrenteResponse?>(
      future: _letturaCorrenteFuture,
      builder: (context, snapshot) {
        final hasLettura = snapshot.hasData && snapshot.data != null;
        final lettura = snapshot.data;
        
        return Column(
          children: [
            // BOTTONE LETTURA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasLettura ? () {
                  // Naviga alla lettura
                  Navigator.pushNamed(context, '/lettura', arguments: {'bookId': libro.id});
                } : _iniziaLettura,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(hasLettura ? Icons.play_arrow : Icons.play_circle_fill),
                    const SizedBox(width: 8),
                    Text(
                      hasLettura ? 'CONTINUA LETTURA' : 'INIZIA LETTURA',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            
            if (hasLettura) ...[
              const SizedBox(height: 12),
              // PROGRESSO LETTURA
              Column(
                children: [
                  LinearProgressIndicator(
                    value: lettura!.paginaCorrente / libro.numeroPagine,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pagina ${lettura.paginaCorrente} di ${libro.numeroPagine} (${((lettura.paginaCorrente / libro.numeroPagine) * 100).toStringAsFixed(1)}%)',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSinossiSection(LibroResponse libro) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sinossi',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          libro.sinossi,
          maxLines: _sinossiEspansa ? null : 4,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        if (libro.sinossi.length > 200)
          TextButton(
            onPressed: () {
              setState(() {
                _sinossiEspansa = !_sinossiEspansa;
              });
            },
            child: Text(
              _sinossiEspansa ? 'Mostra meno' : 'Mostra tutto',
              style: const TextStyle(color: Color(0xFF1E88E5)),
            ),
          ),
      ],
    );
  }

  Widget _buildStatisticheSection(LibroResponse libro) {
    return FutureBuilder<List<FrasePreferitaResponse>>(
      future: _frasiFuture,
      builder: (context, frasiSnapshot) {
        return FutureBuilder<List<CuriositaResponse>>(
          future: _curiositaFuture,
          builder: (context, curiositaSnapshot) {
            final numFrasi = frasiSnapshot.hasData ? frasiSnapshot.data!.length : 0;
            final numCuriosita = curiositaSnapshot.hasData ? curiositaSnapshot.data!.length : 0;
            
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatisticaItem(Icons.format_quote, '$numFrasi', 'Frasi'),
                _buildStatisticaItem(Icons.auto_stories, '$numCuriosita', 'Curiosità'),
                _buildStatisticaItem(Icons.people, '-', 'Lettori'),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatisticaItem(IconData icon, String valore, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1E88E5), size: 24),
        const SizedBox(height: 4),
        Text(
          valore,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCuriositaTab(LibroResponse libro) {
    return FutureBuilder<List<CuriositaResponse>>(
      future: _curiositaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        }
        
        final curiosita = snapshot.data ?? [];
        
        if (curiosita.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_stories, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nessuna curiosità disponibile',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: curiosita.length,
          itemBuilder: (context, index) {
            final curiositaItem = curiosita[index];
            return _buildCuriositaCard(curiositaItem);
          },
        );
      },
    );
  }

  Widget _buildCuriositaCard(CuriositaResponse curiosita) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    curiosita.titolo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (curiosita.paginaRiferimento > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Pag. ${curiosita.paginaRiferimento}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              curiosita.contenuto,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentiTab(LibroResponse libro) {
    return FutureBuilder<LetturaCorrenteResponse?>(
      future: _letturaCorrenteFuture,
      builder: (context, letturaSnapshot) {
        final paginaCorrente = letturaSnapshot.hasData ? _paginaCorrenteUtente : 0;
        
        return Column(
          children: [
            // AVVISO ANTI-SPOILER
            if (paginaCorrente == 0)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.warning_amber, color: Colors.orange, size: 40),
                    const SizedBox(height: 8),
                    const Text(
                      'Inizia la lettura per vedere i commenti',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _iniziaLettura,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('INIZIA LETTURA'),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    // INFO PAGINA CORRENTE
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey[50],
                      child: Text(
                        'Puoi vedere commenti fino a pagina $paginaCorrente',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    // LISTA COMMENTI (placeholder per ora)
                    Expanded(
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Commenti visibili per le pagine lette',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFrasiTab(LibroResponse libro) {
    return FutureBuilder<List<FrasePreferitaResponse>>(
      future: _frasiFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        }
        
        final frasi = snapshot.data ?? [];
        
        return Column(
          children: [
            // BOTTONE AGGIUNGI FRASE
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  _showAggiungiFraseDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('AGGIUNGI FRASE PREFERITA'),
                  ],
                ),
              ),
            ),
            
            // LISTA FRASI
            if (frasi.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.format_quote, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nessuna frase preferita salvata',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: frasi.length,
                  itemBuilder: (context, index) {
                    return _buildFraseCard(frasi[index]);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFraseCard(FrasePreferitaResponse frase) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${frase.testoFrase}"',
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pagina ${frase.paginaRiferimento}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                // TODO: Aggiungi like e condivisione
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAggiungiFraseDialog() {
    final testoController = TextEditingController();
    final paginaController = TextEditingController(text: _paginaCorrenteUtente.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salva Frase Preferita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: testoController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Frase',
                border: OutlineInputBorder(),
                hintText: 'Inserisci la frase che ti è piaciuta...',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: paginaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Pagina',
                border: OutlineInputBorder(),
                hintText: 'Pagina di riferimento',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              final testo = testoController.text.trim();
              final pagina = int.tryParse(paginaController.text) ?? _paginaCorrenteUtente;
              
              if (testo.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Inserisci una frase'), backgroundColor: Colors.red),
                );
                return;
              }
              
              _salvaFrasePreferita(testo, pagina);
              Navigator.pop(context);
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}