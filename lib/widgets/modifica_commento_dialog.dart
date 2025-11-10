import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/commenti_view_model.dart';
import 'package:gld_raccoglitori/models/commento_pagina_response.dart';

class ModificaCommentoDialog extends StatefulWidget 
{
  final CommentoPaginaResponse commento;

  const ModificaCommentoDialog({super.key, required this.commento});

  @override
  State<ModificaCommentoDialog> createState() => _ModificaCommentoDialogState();
}

class _ModificaCommentoDialogState extends State<ModificaCommentoDialog> 
{
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() 
  {
    super.initState();
    _controller.text = widget.commento.contenuto;
  }

  @override
  void dispose() 
  {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return AlertDialog(
      title: const Text('Modifica commento'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          maxLines: 3,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Modifica il tuo commento...',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        Consumer<CommentiViewModel>(
          builder: (context, viewModel, child) 
          {
            return ElevatedButton(
              onPressed: viewModel.isLoading ? null : () => _modificaCommento(context),
              child: viewModel.isLoading ? const CircularProgressIndicator() : const Text('Salva'),
            );
          },
        ),
      ],
    );
  }

  Future<void> _modificaCommento(BuildContext context) async 
  {
    if (_formKey.currentState!.validate()) 
    {
      final viewModel = context.read<CommentiViewModel>();
      final navigator = Navigator.of(context);

      final success = await viewModel.aggiornaCommento(
        commentoId: widget.commento.id,
        nuovoContenuto: _controller.text.trim(),
      );

      if (success) 
      {
        navigator.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commento modificato!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}