import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/lettura_corrente_view_model.dart';
import 'package:gld_raccoglitori/view_models/commenti_view_model.dart';
import 'package:gld_raccoglitori/view_models/curiosita_view_model.dart';
import 'package:gld_raccoglitori/widgets/salva_frase_dialog.dart';
import 'package:gld_raccoglitori/widgets/frasi_preferite_preview_widget.dart';
import 'package:gld_raccoglitori/widgets/curiosita_preview_widget.dart';

class LetturaScreen extends StatefulWidget 
{
  final int bookId;
  final String bookTitle;
  final int? numeroPagineTotali;

  const LetturaScreen({
    super.key,
    required this.bookId,
    required this.bookTitle,
    this.numeroPagineTotali = 350,
  });

  @override
  State<LetturaScreen> createState() => _LetturaScreenState();
}

class _LetturaScreenState extends State<LetturaScreen> 
{
  final TextEditingController _commentoController = TextEditingController();
  String _testoSelezionato = '';

  @override
  void initState() 
  {
    super.initState();
    _inizializzaLettura();
  }

  void _inizializzaLettura() 
  {
    final letturaViewModel = context.read<LetturaCorrenteViewModel>();
    final commentiViewModel = context.read<CommentiViewModel>();
    final curiositaViewModel = context.read<CuriositaViewModel>();

    // Carica le letture dell'utente
    letturaViewModel.caricaMieLetture().then((_) 
    {
      // Verifica se esiste già una lettura per questo libro
      final letturaEsistente = letturaViewModel.getLetturaPerLibro(widget.bookId);
      
      if (letturaEsistente != null) 
      {
        letturaViewModel.impostaLetturaCorrente(letturaEsistente);
        _caricaDatiPaginaCorrente(
          commentiViewModel,
          curiositaViewModel,
          letturaEsistente.id,
          letturaEsistente.paginaCorrente,
        );
      }
    });
  }

  void _caricaDatiPaginaCorrente(
    CommentiViewModel commentiViewModel,
    CuriositaViewModel curiositaViewModel,
    int letturaId,
    int paginaCorrente,
  ) 
  {
    // Carica commenti per la pagina corrente
    commentiViewModel.caricaCommentiPerPagina(
      letturaCorrenteId: letturaId,
      paginaRiferimento: paginaCorrente,
    );

    // Carica curiosità per la pagina corrente
    curiositaViewModel.caricaCuriositaPerPagina(
      libroId: widget.bookId,
      paginaRiferimento: paginaCorrente,
    );
  }

  Future<void> _iniziaNuovaLettura() async 
  {
    final letturaViewModel = context.read<LetturaCorrenteViewModel>();
    final success = await letturaViewModel.iniziaLettura(
      libroId: widget.bookId,
      paginaIniziale: 1,
    );

    if (success)
    {
      _caricaDatiPaginaCorrente(
        context.read<CommentiViewModel>(),
        context.read<CuriositaViewModel>(),
        letturaViewModel.letturaCorrente!.id,
        1,
      );
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lettura: ${widget.bookTitle}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: ()
          {
            Navigator.pushReplacementNamed(context, '/dashboard');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _inizializzaLettura,
            tooltip: 'Ricarica',
          ),
        ],
      ),
      body: Consumer<LetturaCorrenteViewModel>(
        builder: (context, letturaViewModel, child) 
        {
          // Gestione errori
          if (letturaViewModel.error != null) 
          {
            WidgetsBinding.instance.addPostFrameCallback((_) 
            {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(letturaViewModel.error!),
                  backgroundColor: Colors.red,
                ),
              );
              letturaViewModel.clearError();
            });
          }

          return Column(
            children: [
              // HEADER CON PROGRESSO
              _buildHeaderProgresso(letturaViewModel),
              
              // AREA LETTURA PRINCIPALE
              Expanded(
                child: _buildAreaLettura(letturaViewModel),
              ),
              
              // PANEL INTERAZIONE
              _buildPanelInterazione(letturaViewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderProgresso(LetturaCorrenteViewModel letturaViewModel) 
  {
    final percentuale = letturaViewModel.percentualeCompletamento;
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          LinearProgressIndicator(value: percentuale / 100),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pagina ${letturaViewModel.paginaCorrente}'),
              Text('${percentuale.toStringAsFixed(1)}%'),
            ],
          ),
          if (letturaViewModel.letturaCorrente == null) ...[
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _iniziaNuovaLettura,
              child: const Text('Inizia a Leggere'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAreaLettura(LetturaCorrenteViewModel letturaViewModel) 
  {
    if (letturaViewModel.letturaCorrente == null) 
    {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Non stai leggendo questo libro',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Text(
              'Clicca "Inizia a Leggere" per cominciare',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CONTENUTO SIMULATO DELLA PAGINA
          _buildContenutoPagina(letturaViewModel),
          
          const SizedBox(height: 24),
          
          // FRASI PREFERITE (PREVIEW)
          FrasiPreferitePreviewWidget(
            libroId: widget.bookId,
            titoloLibro: widget.bookTitle,
          ),
          
          const SizedBox(height: 16),
          
          // CURIOSITÀ (PREVIEW)
          CuriositaPreviewWidget(
            libroId: widget.bookId,
            paginaRiferimento: letturaViewModel.paginaCorrente,
          ),
          
          const SizedBox(height: 16),
          
          // COMMENTI (PREVIEW)
          _buildCommentiPreview(letturaViewModel),
        ],
      ),
    );
  }

  Widget _buildContenutoPagina(LetturaCorrenteViewModel letturaViewModel) 
  {
  return SelectableText(
    'Contenuto simulato pagina ${letturaViewModel.paginaCorrente}...\n\n'
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
    'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
    'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.\n\n'
    'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum '
    'dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non '
    'proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
    style: const TextStyle(fontSize: 16, height: 1.6),
    onSelectionChanged: (selection, cause) 
    {
      // Solo per debug - mostra che c'è una selezione
      if (selection.isValid && !selection.isCollapsed) 
      {
        print('Testo selezionato (range: ${selection.start}-${selection.end})');
        // In un'app reale, potresti mostrare un menu contestuale
        _mostraMenuContestuale();
      }
    },
  );
  }

  void _mostraMenuContestuale() 
  {
    // Mostra un menu per salvare come frase preferita
    // Anche senza il testo esatto, puoi chiedere all'utente di inserirlo
    showDialog(
      context: context,
      builder: (context) => SalvaFraseDialog(
        libroId: widget.bookId,
        paginaRiferimento: context.read<LetturaCorrenteViewModel>().paginaCorrente,
        titoloLibro: widget.bookTitle,
      ),
    );
  }

  Widget _buildCommentiPreview(LetturaCorrenteViewModel letturaViewModel) 
  {
    return Consumer<CommentiViewModel>(
      builder: (context, commentiViewModel, child) 
      {
        final commenti = commentiViewModel.commenti;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.comment, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Commenti (${commenti.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  if (commenti.isNotEmpty)
                    TextButton(
                      onPressed: () 
                      {
                        Navigator.pushNamed(
                          context,
                          '/commenti',
                          arguments: 
                          {
                            'letturaCorrenteId': letturaViewModel.letturaCorrente!.id,
                            'paginaRiferimento': letturaViewModel.paginaCorrente,
                            'titoloLettura': widget.bookTitle,
                            'utenteCorrenteId': context.read<LetturaCorrenteViewModel>().letturaCorrente?.utenteId,
                          },
                        );
                      },
                      child: const Text('Vedi tutti'),
                    ),
                ],
              ),
            ),
            if (commenti.isNotEmpty)
              ...commenti.take(2).map((commento) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commento.utente.nomeVisualizzato,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        commento.contenuto,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )),
          ],
        );
      },
    );
  }

  Widget _buildPanelInterazione(LetturaCorrenteViewModel letturaViewModel) 
  {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // NAVIGAZIONE PAGINE
          if (letturaViewModel.letturaAttiva)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: letturaViewModel.paginaCorrente > 1 ? () => _vaiPaginaPrecedente(letturaViewModel) : null,
                  child: const Text('← Precedente'),
                ),
                ElevatedButton(
                  onPressed: () => _vaiPaginaSuccessiva(letturaViewModel),
                  child: const Text('Successiva →'),
                ),
              ],
            ),
          
          const SizedBox(height: 12),
          
          // SALVA FRAESE E COMMENTO
          Row(
            children: [
              if (_testoSelezionato.isNotEmpty)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _salvaFrasePreferita(),
                    icon: const Icon(Icons.format_quote),
                    label: const Text('Salva Frase'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
              if (_testoSelezionato.isNotEmpty) const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _commentoController,
                  decoration: InputDecoration(
                    hintText: 'Aggiungi un commento...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _salvaCommento(letturaViewModel),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _vaiPaginaPrecedente(LetturaCorrenteViewModel letturaViewModel) 
  {
    letturaViewModel.vaiPaginaPrecedente().then((success) 
    {
      if (success)
      {
        _ricaricaDatiPagina(letturaViewModel);
      }
    });
  }

  void _vaiPaginaSuccessiva(LetturaCorrenteViewModel letturaViewModel) 
  {
    letturaViewModel.vaiPaginaSuccessiva().then((success) 
    {
      if (success) 
      {
        _ricaricaDatiPagina(letturaViewModel);
      }
    });
  }

  void _ricaricaDatiPagina(LetturaCorrenteViewModel letturaViewModel) 
  {
    if (letturaViewModel.letturaCorrente != null) 
    {
      _caricaDatiPaginaCorrente(
        context.read<CommentiViewModel>(),
        context.read<CuriositaViewModel>(),
        letturaViewModel.letturaCorrente!.id,
        letturaViewModel.paginaCorrente,
      );
    }
  }

  void _salvaFrasePreferita() 
  {
    if (_testoSelezionato.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => SalvaFraseDialog(
        libroId: widget.bookId,
        testoFrasePrecompilato: _testoSelezionato,
        paginaRiferimento: context.read<LetturaCorrenteViewModel>().paginaCorrente,
        titoloLibro: widget.bookTitle,
      ),
    ).then((_) 
    {
      setState(() 
      {
        _testoSelezionato = '';
      });
    });
  }

  void _salvaCommento(LetturaCorrenteViewModel letturaViewModel) async 
  {
    final testo = _commentoController.text.trim();
    if (testo.isEmpty || letturaViewModel.letturaCorrente == null) return;

    final commentiViewModel = context.read<CommentiViewModel>();
    final success = await commentiViewModel.creaCommento(
      letturaCorrenteId: letturaViewModel.letturaCorrente!.id,
      paginaRiferimento: letturaViewModel.paginaCorrente,
      contenuto: testo,
    );

    if (success) 
    {
      _commentoController.clear();
      // I commenti si aggiornano automaticamente tramite il ViewModel
    }
  }

  @override
  void dispose() 
  {
    _commentoController.dispose();
    super.dispose();
  }
}