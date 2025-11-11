import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/raccoglitori_view_model.dart';

class CreaRaccoglitoreDialog extends StatefulWidget 
{
  const CreaRaccoglitoreDialog({super.key});

  @override
  State<CreaRaccoglitoreDialog> createState() => _CreaRaccoglitoreDialogState();
}

class _CreaRaccoglitoreDialogState extends State<CreaRaccoglitoreDialog> 
{
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) 
  {
    return AlertDialog(
      title: const Text('Aggiungi Raccoglitore'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              validator: (value) 
              {
                if (value == null || value.isEmpty) 
                {
                  return 'Inserisci il nome';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cognomeController,
              decoration: const InputDecoration(
                labelText: 'Cognome',
                border: OutlineInputBorder(),
              ),
              validator: (value) 
              {
                if (value == null || value.isEmpty) 
                {
                  return 'Inserisci il cognome';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _creaRaccoglitore,
          child: _isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Crea'),
        ),
      ],
    );
  }

  Future<void> _creaRaccoglitore() async 
  {
    if (_formKey.currentState!.validate()) 
    {
      setState(() => _isLoading = true);

      final viewModel = context.read<RaccoglitoriViewModel>();
      final success = await viewModel.creaRaccoglitore(
        _nomeController.text,
        _cognomeController.text,
      );

      if (success && mounted) 
      {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Raccoglitore creato con successo!')),
        );
      } 
      else if (mounted) 
      {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() 
  {
    _nomeController.dispose();
    _cognomeController.dispose();
    super.dispose();
  }
}