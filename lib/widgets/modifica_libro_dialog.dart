import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/libro_view_model.dart';
import 'package:gld_raccoglitori/models/libro_response.dart';
import 'package:gld_raccoglitori/models/LibroRequestModel.dart';

class ModificaLibroDialog extends StatefulWidget 
{
  final LibroResponse libro;

  const ModificaLibroDialog({
    super.key,
    required this.libro,
  });

  @override
  State<ModificaLibroDialog> createState() => _ModificaLibroDialogState();
}

class _ModificaLibroDialogState extends State<ModificaLibroDialog> 
{
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titoloController;
  late TextEditingController _autoreController;
  late TextEditingController _copertinaController;
  late TextEditingController _sinossiController;
  late TextEditingController _annoController;
  late TextEditingController _pagineController;

  @override
  void initState() 
  {
    super.initState();
    // Inizializza i controller con i valori esistenti del libro
    _titoloController = TextEditingController(text: widget.libro.titolo);
    _autoreController = TextEditingController(text: widget.libro.autore);
    _copertinaController = TextEditingController(text: widget.libro.copertinaUrl);
    _sinossiController = TextEditingController(text: widget.libro.sinossi);
    _annoController = TextEditingController(text: widget.libro.annoPubblicazione.toString());
    _pagineController = TextEditingController(text: widget.libro.numeroPagine.toString());
  }

  @override
  void dispose() 
  {
    _titoloController.dispose();
    _autoreController.dispose();
    _copertinaController.dispose();
    _sinossiController.dispose();
    _annoController.dispose();
    _pagineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return AlertDialog(
      title: const Text('Modifica Libro'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titoloController,
                decoration: const InputDecoration(
                  labelText: 'Titolo *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) 
                  {
                    return 'Inserisci il titolo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _autoreController,
                decoration: const InputDecoration(
                  labelText: 'Autore *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) 
                {
                  if (value == null || value.isEmpty) 
                  {
                    return 'Inserisci l\'autore';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _copertinaController,
                decoration: const InputDecoration(
                  labelText: 'URL Copertina',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/copertina.jpg',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sinossiController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Sinossi',
                  border: OutlineInputBorder(),
                  hintText: 'Breve descrizione del libro...',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _annoController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Anno *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) 
                        {
                          return 'Inserisci l\'anno';
                        }
                        if (int.tryParse(value) == null) 
                        {
                          return 'Inserisci un anno valido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _pagineController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Pagine *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) 
                      {
                        if (value == null || value.isEmpty) 
                        {
                          return 'Inserisci il numero di pagine';
                        }
                        if (int.tryParse(value) == null) 
                        {
                          return 'Inserisci un numero valido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        Consumer<LibroViewModel>(
          builder: (context, viewModel, child) 
          {
            return ElevatedButton(
              onPressed: viewModel.isLoading ? null : () => _modificaLibro(context),
              child: viewModel.isLoading 
                  ? const CircularProgressIndicator() 
                  : const Text('Salva Modifiche'),
            );
          },
        ),
      ],
    );
  }

  Future<void> _modificaLibro(BuildContext context) async 
  {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<LibroViewModel>();
    final navigator = Navigator.of(context);

    // Crea il request model per l'aggiornamento
    final request = LibroRequestModel(
      titolo: _titoloController.text.trim(),
      autore: _autoreController.text.trim(),
      copertinaUrl: _copertinaController.text.trim(),
      sinossi: _sinossiController.text.trim(),
      annoPubblicazione: int.parse(_annoController.text),
      numeroPagine: int.parse(_pagineController.text),
    );

    final success = await viewModel.aggiornaLibro(
      id: widget.libro.id,
      request: request,
    );

    if (success) 
    {
      navigator.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Libro modificato con successo!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore durante la modifica del libro'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}