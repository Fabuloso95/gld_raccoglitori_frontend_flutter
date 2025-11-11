import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/proposta_voto_view_model.dart';
import 'package:gld_raccoglitori/view_models/voto_utente_view_model.dart';
import 'package:gld_raccoglitori/view_models/libro_view_model.dart';
import 'package:gld_raccoglitori/widgets/proposta_voto_card.dart';
import 'package:gld_raccoglitori/widgets/seleziona_libro_dialog.dart';

class VotazioniScreen extends StatefulWidget 
{
  const VotazioniScreen({super.key});

  @override
  State<VotazioniScreen> createState() => _VotazioniScreenState();
}

class _VotazioniScreenState extends State<VotazioniScreen> with SingleTickerProviderStateMixin 
{
  late TabController _tabController;

  @override
  void initState() 
  {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _caricaProposteCorrenti();
  }

  void _caricaProposteCorrenti() 
  {
    final viewModel = context.read<PropostaVotoViewModel>();
    viewModel.caricaProposteMeseCorrente();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Votazioni Libri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _mostraDialogoProponiLibro(context),
            tooltip: 'Proponi Libro',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _caricaProposteCorrenti,
            tooltip: 'Ricarica',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.today), text: 'Mese Corrente'),
            Tab(icon: Icon(Icons.history), text: 'Archivio'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabCorrente(),
          _buildTabArchivio(),
        ],
      ),
    );
  }

  Widget _buildTabCorrente() 
  {
    return Consumer2<PropostaVotoViewModel, VotoUtenteViewModel>(
      builder: (context, propostaVM, votoVM, child) 
      {
        if (propostaVM.isLoading && propostaVM.proposteCorrenti.isEmpty) 
        {
          return const Center(child: CircularProgressIndicator());
        }

        if (propostaVM.error != null) 
        {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Errore: ${propostaVM.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () 
                  {
                    propostaVM.clearError();
                    _caricaProposteCorrenti();
                  },
                  child: const Text('Riprova'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildHeaderInfo(propostaVM, votoVM),
            Expanded(
              child: propostaVM.proposteCorrenti.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: propostaVM.proposteCorrenti.length,
                      itemBuilder: (context, index) {
                        final proposta = propostaVM.proposteCorrenti[index];
                        return PropostaVotoCard(proposta: proposta);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderInfo(PropostaVotoViewModel propostaVM, VotoUtenteViewModel votoVM) 
  {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Votazioni ${propostaVM.meseCorrente}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  'Proposte',
                  propostaVM.proposteCorrenti.length.toString(),
                  Icons.library_books,
                ),
                _buildInfoItem(
                  'Tuoi Voti',
                  '${votoVM.votiUtenteCorrente.length}/3',
                  Icons.how_to_vote,
                ),
                _buildInfoItem(
                  'Voti Rimanenti',
                  votoVM.votiRimanenti.toString(),
                  Icons.assignment_turned_in,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) 
  {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildEmptyState() 
  {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.library_books, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Nessuna proposta di voto',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sii il primo a proporre un libro per questo mese!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _mostraDialogoProponiLibro(context),
            icon: const Icon(Icons.add),
            label: const Text('Proponi Libro'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabArchivio() 
  {
    return const Center(
      child: Text(
        'Archivio votazioni - Funzionalità in sviluppo',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  void _mostraDialogoProponiLibro(BuildContext context) 
  {
    final propostaViewModel = context.read<PropostaVotoViewModel>();
    final libroViewModel = context.read<LibroViewModel>();

    if (libroViewModel.libri.isEmpty) 
    {
      libroViewModel.caricaLibri();
    }

    showDialog(
      context: context,
      builder: (context) => SelezionaLibroDialog(
        onLibroSelezionato: (libro) async 
        {
          final success = await propostaViewModel.proponiLibro(libro.id);
          if (success && mounted) 
          {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('"${libro.titolo}" proposto con successo!')),
            );
          }
        },
        libriEsclusi: propostaViewModel.proposteCorrenti
            .map((p) => p.libroProposto.id)
            .toList(),
      ),
    );
  }
}