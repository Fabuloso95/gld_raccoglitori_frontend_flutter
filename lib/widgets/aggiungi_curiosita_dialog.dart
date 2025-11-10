import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/curiosita_view_model.dart';

class AggiungiCuriositaDialog extends StatefulWidget {
  final int libroId;
  final int numeroPagineTotali;

  const AggiungiCuriositaDialog({
    super.key,
    required this.libroId,
    required this.numeroPagineTotali,
  });

  @override
  State<AggiungiCuriositaDialog> createState() => _AggiungiCuriositaDialogState();
}

class _AggiungiCuriositaDialogState extends State<AggiungiCuriositaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titoloController = TextEditingController();
  final _contenutoController = TextEditingController();
  int? _paginaRiferimento;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aggiungi Curiosità'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titoloController,
              decoration: const InputDecoration(
                labelText: 'Titolo',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Inserisci un titolo';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contenutoController,
              decoration: const InputDecoration(
                labelText: 'Contenuto',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Inserisci il contenuto';
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
                ...List.generate(widget.numeroPagineTotali, (index) {
                  final pagina = index + 1;
                  return DropdownMenuItem(
                    value: pagina,
                    child: Text('Pagina $pagina'),
                  );
                }),
              ],
              onChanged: (value) {
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
          onPressed: _salvaCuriosita,
          child: const Text('Salva'),
        ),
      ],
    );
  }

  Future<void> _salvaCuriosita() async {
    if (_formKey.currentState!.validate()) {
      final viewModel = context.read<CuriositaViewModel>();
      final success = await viewModel.creaCuriositaRapida(
        libroId: widget.libroId,
        titolo: _titoloController.text,
        contenuto: _contenutoController.text,
        paginaRiferimento: _paginaRiferimento ?? 0,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Curiosità salvata con successo!')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titoloController.dispose();
    _contenutoController.dispose();
    super.dispose();
  }
}