import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/libro_view_model.dart';

class CreaLibroDialog extends StatefulWidget 
{
  const CreaLibroDialog({super.key});

  @override
  State<CreaLibroDialog> createState() => _CreaLibroDialogState();
}

class _CreaLibroDialogState extends State<CreaLibroDialog> 
{
  final _formKey = GlobalKey<FormState>();
  final _titoloController = TextEditingController();
  final _autoreController = TextEditingController();
  final _copertinaController = TextEditingController();
  final _sinossiController = TextEditingController();
  final _annoController = TextEditingController();
  final _pagineController = TextEditingController();

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
      title: const Text('Aggiungi Nuovo Libro'),
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
              onPressed: viewModel.isLoading ? null : () => _creaLibro(context),
              child: viewModel.isLoading ? const CircularProgressIndicator() : const Text('Aggiungi'),
            );
          },
        ),
      ],
    );
  }

  Future<void> _creaLibro(BuildContext context) async 
  {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<LibroViewModel>();
    final navigator = Navigator.of(context);

    // Verifica se il libro esiste già
    if (viewModel.libroEsisteGia(
      _titoloController.text.trim(),
      _autoreController.text.trim(),
    )) 
    {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Un libro con lo stesso titolo e autore esiste già!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await viewModel.creaLibroRapido(
      titolo: _titoloController.text.trim(),
      autore: _autoreController.text.trim(),
      copertinaUrl: _copertinaController.text.trim(),
      sinossi: _sinossiController.text.trim(),
      annoPubblicazione: int.parse(_annoController.text),
      numeroPagine: int.parse(_pagineController.text),
    );

    if (success) 
    {
      navigator.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Libro aggiunto con successo!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}