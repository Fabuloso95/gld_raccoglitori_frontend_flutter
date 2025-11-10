import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/commenti_view_model.dart';
import 'package:gld_raccoglitori/models/commento_pagina_response.dart';
import '../widgets/modifica_commento_dialog.dart';

class ListaCommentiScreen extends StatefulWidget 
{
  final int letturaCorrenteId;
  final int paginaRiferimento;
  final String? titoloLettura;
  final int utenteCorrenteId;

  const ListaCommentiScreen({
    super.key,
    required this.letturaCorrenteId,
    required this.paginaRiferimento,
    this.titoloLettura,
    required this.utenteCorrenteId,
  });

  @override
  State<ListaCommentiScreen> createState() => _ListaCommentiScreenState();
}

class _ListaCommentiScreenState extends State<ListaCommentiScreen> 
{
  final TextEditingController _commentoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() 
  {
    super.initState();
    _caricaCommenti();
  }

  void _caricaCommenti() 
  {
    final viewModel = context.read<CommentiViewModel>();
    viewModel.caricaCommentiPerPagina(
      letturaCorrenteId: widget.letturaCorrenteId,
      paginaRiferimento: widget.paginaRiferimento,
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.titoloLettura != null ? 'Commenti - ${widget.titoloLettura}' : 'Commenti Pagina ${widget.paginaRiferimento}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _caricaCommenti,
          ),
        ],
      ),
      body: Column(
        children: [
          // Form per nuovo commento
          _NuovoCommentoForm(
            formKey: _formKey,
            controller: _commentoController,
            onInviaCommento: _inviaCommento,
          ),

          // Lista commenti
          Expanded(
            child: Consumer<CommentiViewModel>(
              builder: (context, viewModel, child) 
              {
                if (viewModel.isLoading && viewModel.commenti.isEmpty) 
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
                            _caricaCommenti();
                          },
                          child: const Text('Riprova'),
                        ),
                      ],
                    ),
                  );
                }

                final commenti = viewModel.commenti;

                if (commenti.isEmpty) 
                {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.comment_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nessun commento ancora',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        Text(
                          'Sii il primo a commentare!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: commenti.length,
                  itemBuilder: (context, index) 
                  {
                    final commento = commenti[index];
                    return _CommentoCard(commento: commento, utenteCorrenteId: widget.utenteCorrenteId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _inviaCommento(String contenuto) async 
  {
    if (contenuto.trim().isEmpty) return;

    final viewModel = context.read<CommentiViewModel>();
    
    final success = await viewModel.creaCommento(
      letturaCorrenteId: widget.letturaCorrenteId,
      paginaRiferimento: widget.paginaRiferimento,
      contenuto: contenuto.trim(),
    );

    if (success) 
    {
      _commentoController.clear();
      _formKey.currentState?.reset();
      
      // Mostra messaggio di successo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commento pubblicato!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// Widget per il form di nuovo commento
class _NuovoCommentoForm extends StatelessWidget 
{
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final Function(String) onInviaCommento;

  const _NuovoCommentoForm({
    required this.formKey,
    required this.controller,
    required this.onInviaCommento,
  });

  @override
  Widget build(BuildContext context) 
  {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aggiungi un commento',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Scrivi il tuo commento...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12.0),
              ),
              validator: (value) 
              {
                if (value == null || value.trim().isEmpty) 
                {
                  return 'Il commento non può essere vuoto';
                }
                if (value.trim().length < 2) 
                {
                  return 'Il commento deve essere di almeno 2 caratteri';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Consumer<CommentiViewModel>(
              builder: (context, viewModel, child) 
              {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading ? null : () 
                    {
                      if (formKey.currentState!.validate()) 
                      {
                              onInviaCommento(controller.text);
                      }
                    },
                    child: viewModel.isLoading ? const CircularProgressIndicator() : const Text('Pubblica Commento'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Widget per la card del commento
class _CommentoCard extends StatelessWidget 
{
  final CommentoPaginaResponse commento;
  final int? utenteCorrenteId;

  const _CommentoCard({
    required this.commento,
    this.utenteCorrenteId,
  });

  @override
  Widget build(BuildContext context) 
  {
    final isMioCommento = utenteCorrenteId == commento.utente.id;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con info utente e data
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isMioCommento ? Colors.green : Colors.blue,
                  child: Text(
                    commento.utente.iniziale,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    commento.utente.nomeVisualizzato,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isMioCommento ? Colors.green : Colors.black,
                    ),
                  ),
                ),
                Text(
                  _formattaData(commento.dataCreazione),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Contenuto del commento
            Text(commento.contenuto),
            
            const SizedBox(height: 8),
            
            // Azioni (solo per i propri commenti)
            if (isMioCommento) _AzioniCommento(commento: commento),
          ],
        ),
      ),
    );
  }

  String _formattaData(DateTime data) 
  {
    final now = DateTime.now();
    final difference = now.difference(data);

    if (difference.inMinutes < 1) 
    {
      return 'Ora';
    } 
    else if (difference.inHours < 1) 
    {
      return '${difference.inMinutes}m fa';
    } 
    else if (difference.inDays < 1) 
    {
      return '${difference.inHours}h fa';
    } 
    else if (difference.inDays < 7) 
    {
      return '${difference.inDays}g fa';
    } 
    else 
    {
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
    }
  }
}

// Widget per le azioni del commento (modifica/elimina)
class _AzioniCommento extends StatelessWidget 
{
  final CommentoPaginaResponse commento;

  const _AzioniCommento({required this.commento});

  @override
  Widget build(BuildContext context) 
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => _modificaCommento(context),
          child: const Text(
            'Modifica',
            style: TextStyle(fontSize: 12),
          ),
        ),
        TextButton(
          onPressed: () => _eliminaCommento(context),
          child: const Text(
            'Elimina',
            style: TextStyle(fontSize: 12, color: Colors.red),
          ),
        ),
      ],
    );
  }

  void _modificaCommento(BuildContext context) 
  {
    showDialog(
      context: context,
      builder: (context) => ModificaCommentoDialog(commento: commento),
    );
  }

  void _eliminaCommento(BuildContext context) 
  {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina commento'),
        content: const Text('Sei sicuro di voler eliminare questo commento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              context.read<CommentiViewModel>().eliminaCommento(commento.id);
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