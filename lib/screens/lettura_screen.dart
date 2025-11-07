import 'package:flutter/material.dart';
import 'package:gld_raccoglitori/models/CommentoPaginaRequestModel.dart';
import 'package:provider/provider.dart';
import '../models/LetturaCorrenteUpdateRequestModel.dart';
import '../services/auth_service.dart';
import '../services/lettura_corrente_api_service.dart';
import '../services/commenti_api_service.dart';
import '../services/curiosita_api_service.dart';
import '../models/lettura_corrente_response.dart';
import '../models/commento_pagina_response.dart';
import '../models/curiosita_response.dart';

class LetturaScreen extends StatefulWidget {
  final int bookId;
  final String bookTitle;

  const LetturaScreen({super.key, required this.bookId, required this.bookTitle});

  @override
  State<LetturaScreen> createState() => _LetturaScreenState();
}

class _LetturaScreenState extends State<LetturaScreen> {
  // ✅ VARIABILI STATO
  int _paginaCorrente = 1;
  bool _isLoading = false;
  String _testoSelezionato = '';
  
  // ✅ CONTROLLER
  final TextEditingController _commentoController = TextEditingController();
  
  // ✅ FUTURE - chiamate ai service
  late Future<LetturaCorrenteResponse?> _letturaFuture;
  late Future<List<CommentoPaginaResponse>> _commentiFuture;
  late Future<List<CuriositaResponse>> _curiositaFuture;

  @override
  void initState() {
    super.initState();
    _loadLetturaData();
  }

  // ✅ CHIAMATE AI SERVICE
  void _loadLetturaData() {
    final letturaService = Provider.of<LetturaCorrenteApiService>(context, listen: false);
    final commentiService = Provider.of<CommentiApiService>(context, listen: false);
    final curiositaService = Provider.of<CuriositaApiService>(context, listen: false);

    _letturaFuture = _getLetturaCorrente(letturaService);
    _commentiFuture = commentiService.getCommentiByLetturaAndPagina(
      letturaCorrenteId: 1, // TODO: ottenere ID lettura corrente
      paginaRiferimento: _paginaCorrente,
    );
  }

  Future<LetturaCorrenteResponse?> _getLetturaCorrente(LetturaCorrenteApiService service) async {
    try {
      final letture = await service.getMyReadings();
      return letture.where((l) => l.libroId == widget.bookId).firstOrNull;
    } catch (e) {
      print('Errore: $e');
      return null;
    }
  }

  Future<void> _aggiornaProgresso(int nuovaPagina) async {
    setState(() {
      _isLoading = true;
      _paginaCorrente = nuovaPagina;
    });

    try {
      final letturaService = Provider.of<LetturaCorrenteApiService>(context, listen: false);
      final lettura = await _letturaFuture;
      
      if (lettura != null) {
        await letturaService.updateProgress(
          id: lettura.id,
          request: LetturaCorrenteUpdateRequestModel(
            paginaCorrente: nuovaPagina,
            partecipaChiamataZoom: true,
          ),
        );
        
        // Ricarica dati per nuova pagina
        _loadLetturaData();
      }
    } catch (e) {
      // Gestione errore
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _salvaCommento() async {
  final testo = _commentoController.text.trim();
  if (testo.isEmpty) return;

  try {
    final authService = Provider.of<AuthService>(context, listen: false);
    // ✅ Crea il service direttamente con i parametri richiesti
    final commentiService = CommentiApiService(
      authService: authService,
      baseUrl: "http://localhost:8080",
    );
    
    final lettura = await _letturaFuture;
    
    if (lettura != null) {
      await commentiService.createCommento(CommentoPaginaRequestModel(
        letturaCorrenteId: lettura.id,
        paginaRiferimento: _paginaCorrente,
        contenuto: testo,
      ));
      
      _commentoController.clear();
      _loadLetturaData(); // Ricarica commenti
    }
  } catch (e) {
    print('Errore salvataggio commento: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lettura: ${widget.bookTitle}'),
      ),
      body: Column(
        children: [
          // ✅ HEADER CON PROGRESSO
          _buildHeaderProgresso(),
          
          // ✅ AREA LETTURA
          Expanded(
            child: _buildAreaLettura(),
          ),
          
          // ✅ COMMENTI E CURIOSITÀ
          _buildPanelInterazione(),
        ],
      ),
    );
  }

  // ✅ SOLO UI - niente logica business
  Widget _buildHeaderProgresso() {
    return FutureBuilder<LetturaCorrenteResponse?>(
      future: _letturaFuture,
      builder: (context, snapshot) {
        final progresso = snapshot.hasData ? (_paginaCorrente / 350 * 100) : 0;
        
        return Container(
          padding: EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Column(
            children: [
              LinearProgressIndicator(value: progresso / 100),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pagina $_paginaCorrente'),
                  Text('${progresso.toStringAsFixed(1)}%'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ SOLO UI - contenuto simulato
  Widget _buildAreaLettura() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: SelectableText(
        'Contenuto simulato pagina $_paginaCorrente...\n\n'
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
        'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
        'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
        style: TextStyle(fontSize: 16, height: 1.6),
        onSelectionChanged: (selection, cause) {
          // Gestione selezione testo per frasi preferite
        },
      ),
    );
  }

  // ✅ SOLO UI - interazioni
  Widget _buildPanelInterazione() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // NAVIGAZIONE PAGINE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _paginaCorrente > 1 ? _vaiPaginaPrecedente : null,
                child: Text('← Precedente'),
              ),
              ElevatedButton(
                onPressed: _vaiPaginaSuccessiva,
                child: Text('Successiva →'),
              ),
            ],
          ),
          
          // COMMENTO RAPIDO
          TextField(
            controller: _commentoController,
            decoration: InputDecoration(
              hintText: 'Aggiungi un commento per questa pagina...',
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: _salvaCommento,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _vaiPaginaPrecedente() => _aggiornaProgresso(_paginaCorrente - 1);
  void _vaiPaginaSuccessiva() => _aggiornaProgresso(_paginaCorrente + 1);
}