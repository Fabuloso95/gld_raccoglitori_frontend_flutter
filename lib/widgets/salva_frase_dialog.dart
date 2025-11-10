import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/frase_preferita_view_model.dart';
import 'package:gld_raccoglitori/view_models/auth_view_model.dart';

class SalvaFraseDialog extends StatefulWidget 
{
  final int libroId;
  final String? testoFrasePrecompilato;
  final int? paginaRiferimento;
  final String? titoloLibro;

  const SalvaFraseDialog({
    super.key,
    required this.libroId,
    this.testoFrasePrecompilato,
    this.paginaRiferimento,
    this.titoloLibro,
  });

  @override
  State<SalvaFraseDialog> createState() => _SalvaFraseDialogState();
}

class _SalvaFraseDialogState extends State<SalvaFraseDialog> 
{
  final _formKey = GlobalKey<FormState>();
  final _testoFraseController = TextEditingController();
  final _paginaController = TextEditingController();

  @override
  void initState() 
  {
    super.initState();
    if (widget.testoFrasePrecompilato != null) 
    {
      _testoFraseController.text = widget.testoFrasePrecompilato!;
    }
    if (widget.paginaRiferimento != null) 
    {
      _paginaController.text = widget.paginaRiferimento!.toString();
    }
  }

  @override
  void dispose() 
  {
    _testoFraseController.dispose();
    _paginaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return AlertDialog(
      title: const Text('Salva Frase Preferita'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.titoloLibro != null) ...[
              Text(
                'Libro: ${widget.titoloLibro}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
            ],
            TextFormField(
              controller: _testoFraseController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Frase *',
                border: OutlineInputBorder(),
                hintText: 'Inserisci la frase che ti ha colpito...',
              ),
              validator: (value) 
              {
                if (value == null || value.trim().isEmpty) 
                {
                  return 'Inserisci la frase';
                }
                if (value.trim().length < 5) 
                {
                  return 'La frase deve essere di almeno 5 caratteri';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _paginaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Pagina (opzionale)',
                border: OutlineInputBorder(),
                hintText: 'Numero pagina',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        Consumer<FrasePreferitaViewModel>(
          builder: (context, fraseViewModel, child) 
          {
            return Consumer<AuthViewModel>(
              builder: (context, authViewModel, child) 
              {
                return ElevatedButton(
                  onPressed: fraseViewModel.isLoading ? null : () => _salvaFrase(context, authViewModel.currentUserId),
                  child: fraseViewModel.isLoading ? const CircularProgressIndicator() : const Text('Salva'),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _salvaFrase(BuildContext context, int? utenteId) async 
  {
    if (!_formKey.currentState!.validate()) return;

    if (utenteId == null) 
    {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Devi essere loggato per salvare frasi preferite'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final viewModel = context.read<FrasePreferitaViewModel>();
    final navigator = Navigator.of(context);

    // Verifica se la frase esiste già
    if (viewModel.fraseEsisteGia(_testoFraseController.text.trim(), widget.libroId)) 
    {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hai già salvato questa frase!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await viewModel.salvaFraseRapida(
      utenteId: utenteId,
      libroId: widget.libroId,
      testoFrase: _testoFraseController.text.trim(),
      paginaRiferimento: int.tryParse(_paginaController.text) ?? 0,
    );

    if (success) 
    {
      navigator.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Frase salvata con successo!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}