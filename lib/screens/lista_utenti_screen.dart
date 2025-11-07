import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/utente_view_model.dart';
import '../widgets/cambia_ruolo_dialog.dart';
import 'crea_utente_screen.dart';

class ListaUtentiScreen extends StatelessWidget 
{
  const ListaUtentiScreen({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Utenti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () 
            {
              context.read<UtenteViewModel>().caricaUtenti();
            },
          ),
        ],
      ),
      body: Consumer<UtenteViewModel>(
        builder: (context, viewModel, child) 
        {
          // Gestione dello stato di caricamento
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Gestione degli errori
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
                    onPressed: () {
                      viewModel.clearError();
                      viewModel.caricaUtenti();
                    },
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            );
          }

          // Lista degli utenti
          return ListView.builder(
            itemCount: viewModel.utentiFiltrati.length,
            itemBuilder: (context, index) 
            {
              final utente = viewModel.utentiFiltrati[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(utente.nome[0]),
                ),
                title: Text('${utente.nome} ${utente.cognome}'),
                subtitle: Text(utente.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      utente.attivo ? Icons.check_circle : Icons.remove_circle,
                      color: utente.attivo ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(utente.ruolo.nome),
                  ],
                ),
                onTap: () 
                {
                  // Naviga alla schermata di dettaglio
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DettaglioUtenteScreen(utenteId: utente.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () 
        {
          // Naviga alla schermata di creazione utente
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreaUtenteScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DettaglioUtenteScreen extends StatelessWidget 
{
  final int utenteId;

  const DettaglioUtenteScreen({super.key, required this.utenteId});

  @override
  Widget build(BuildContext context) 
  {
    final viewModel = context.read<UtenteViewModel>();

    // Carica i dettagli dell'utente quando lo screen viene inizializzato
    WidgetsBinding.instance.addPostFrameCallback((_) 
    {
      viewModel.caricaUtentePerId(utenteId);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio Utente'),
      ),
      body: Consumer<UtenteViewModel>(
        builder: (context, viewModel, child) 
        {
          final utente = viewModel.utenteSelezionato;

          if (viewModel.isLoading) 
          {
            return const Center(child: CircularProgressIndicator());
          }

          if (utente == null) 
          {
            return const Center(child: Text('Utente non trovato'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nome: ${utente.nome} ${utente.cognome}'),
                Text('Email: ${utente.email}'),
                Text('Username: ${utente.username}'),
                Text('Ruolo: ${utente.ruolo.nome}'),
                Text('Stato: ${utente.attivo ? "Attivo" : "Disattivato"}'),
                Text('Data registrazione: ${utente.dataRegistrazione}'),
                
                const SizedBox(height: 20),
                
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () 
                      {
                        // Attiva/Disattiva utente
                        if (utente.attivo) 
                        {
                          viewModel.disattivaUtente(utente.id);
                        } 
                        else 
                        {
                          viewModel.attivaUtente(utente.id);
                        }
                      },
                      child: Text(utente.attivo ? 'Disattiva' : 'Attiva'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () 
                      {
                        // Cambia ruolo
                        showDialog(
                          context: context,
                          builder: (context) => CambiaRuoloDialog(utenteId: utente.id),
                        );
                      },
                      child: const Text('Cambia Ruolo'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}