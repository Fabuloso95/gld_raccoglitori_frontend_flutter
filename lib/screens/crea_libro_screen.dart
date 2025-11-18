import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/libro_view_model.dart';

class CreaLibroScreen extends StatefulWidget 
{
  const CreaLibroScreen({super.key});

  @override
  State<CreaLibroScreen> createState() => _CreaLibroScreenState();
}

class _CreaLibroScreenState extends State<CreaLibroScreen> 
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggiungi Nuovo Libro'),
        actions: [
          Consumer<LibroViewModel>(
            builder: (context, viewModel, child) 
            {
              return IconButton(
                icon: viewModel.isLoading ? const CircularProgressIndicator() : const Icon(Icons.save),
                onPressed: viewModel.isLoading ? null : _salvaLibro,
                tooltip: 'Salva Libro',
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAnteprimaCopertina(),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _titoloController,
                  decoration: const InputDecoration(
                    labelText: 'Titolo *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) 
                  {
                    if (value == null || value.isEmpty) 
                    {
                      return 'Il titolo è obbligatorio';
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
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) 
                  {
                    if (value == null || value.isEmpty) 
                    {
                      return 'L\'autore è obbligatorio';
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
                    prefixIcon: Icon(Icons.image),
                    hintText: 'https://example.com/copertina.jpg',
                  ),
                  onChanged: (value) 
                  {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _sinossiController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Sinossi',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
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
                          labelText: 'Anno Pubblicazione *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        validator: (value) 
                        {
                          if (value == null || value.isEmpty) 
                          {
                            return 'L\'anno è obbligatorio';
                          }
                          if (int.tryParse(value) == null) 
                          {
                            return 'Inserisci un anno valido';
                          }
                          final anno = int.parse(value);
                          if (anno < 1000 || anno > DateTime.now().year) 
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
                          labelText: 'Numero Pagine *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.format_list_numbered),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) 
                          {
                            return 'Il numero di pagine è obbligatorio';
                          }
                          if (int.tryParse(value) == null) 
                          {
                            return 'Inserisci un numero valido';
                          }
                          final pagine = int.parse(value);
                          if (pagine <= 0) 
                          {
                            return 'Inserisci un numero positivo';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // BOTTONE SALVA
                Consumer<LibroViewModel>(
                  builder: (context, viewModel, child) 
                  {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: viewModel.isLoading ? null : _salvaLibro,
                        icon: viewModel.isLoading 
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.save),
                        label: Text(
                          viewModel.isLoading ? 'Salvataggio...' : 'Salva Libro',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnteprimaCopertina() 
  {
    final url = _copertinaController.text.trim();
    
    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: url.isEmpty
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Anteprima\ncopertina',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) 
                {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'URL non\nvalido',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Future<void> _salvaLibro() async 
  {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<LibroViewModel>();
    
    // Verifica duplicati
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

    if (success && mounted) 
    {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Libro aggiunto con successo!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}