import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/frase_preferita_view_model.dart';
import 'package:gld_raccoglitori/services/auth_service.dart';

class AggiungiFrasePreferitaDialog extends StatefulWidget 
{
  final int libroId;
  final int numeroPagineTotali;

  const AggiungiFrasePreferitaDialog({
    super.key,
    required this.libroId,
    required this.numeroPagineTotali,
  });

  @override
  State<AggiungiFrasePreferitaDialog> createState() => _AggiungiFrasePreferitaDialogState();
}

class _AggiungiFrasePreferitaDialogState extends State<AggiungiFrasePreferitaDialog> 
{
  final _formKey = GlobalKey<FormState>();
  final _testoController = TextEditingController();
  int? _paginaRiferimento;

  @override
  Widget build(BuildContext context) 
  {
    return AlertDialog(
      title: const Text('Aggiungi Frase Preferita'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _testoController,
              decoration: const InputDecoration(
                labelText: 'Testo della frase',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) 
              {
                if (value == null || value.isEmpty) 
                {
                  return 'Inserisci il testo della frase';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _paginaRiferimento,
              decoration: const InputDecoration(
                labelText: 'Pagina riferimento (opzionale)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Nessuna pagina specifica'),
                ),
                ...List.generate(widget.numeroPagineTotali, (index) 
                {
                  final pagina = index + 1;
                  return DropdownMenuItem(
                    value: pagina,
                    child: Text('Pagina $pagina'),
                  );
                }),
              ],
              onChanged: (value) 
              {
                setState(() {
                  _paginaRiferimento = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: _salvaFrase,
          child: const Text('Salva'),
        ),
      ],
    );
  }

  Future<void> _salvaFrase() async 
  {
    if (_formKey.currentState!.validate()) 
    {
      final authService = context.read<AuthService>();
      final utenteId = authService.currentUserId;
      
      if (utenteId == null) 
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utente non autenticato')),
        );
        return;
      }

      final viewModel = context.read<FrasePreferitaViewModel>();
      final success = await viewModel.salvaFraseRapida(
        utenteId: utenteId,
        libroId: widget.libroId,
        testoFrase: _testoController.text,
        paginaRiferimento: _paginaRiferimento ?? 0,
      );

      if (success && mounted) 
      {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Frase salvata con successo!')),
        );
      }
    }
  }

  @override
  void dispose() 
  {
    _testoController.dispose();
    super.dispose();
  }
}