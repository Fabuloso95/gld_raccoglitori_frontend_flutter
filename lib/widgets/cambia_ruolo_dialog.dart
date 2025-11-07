import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/utente_view_model.dart';

class CambiaRuoloDialog extends StatefulWidget 
{
  final int utenteId;

  const CambiaRuoloDialog({
    super.key,
    required this.utenteId,
  });

  @override
  State<CambiaRuoloDialog> createState() => _CambiaRuoloDialogState();
}

class _CambiaRuoloDialogState extends State<CambiaRuoloDialog> 
{
  String? _ruoloSelezionato;
  final List<String> _ruoliDisponibili = ['USER', 'ADMIN'];

  @override
  Widget build(BuildContext context) 
  {
    return AlertDialog(
      title: const Text('Cambia Ruolo Utente'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Seleziona il nuovo ruolo:'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _ruoloSelezionato,
            hint: const Text('Seleziona ruolo'),
            items: _ruoliDisponibili
                .map((ruolo) => DropdownMenuItem(
                      value: ruolo,
                      child: Text(
                        ruolo,
                        style: TextStyle(
                          fontWeight: ruolo == 'ADMIN' 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                    ))
                .toList(),
            onChanged: (String? newValue) 
            {
              setState(() {
                _ruoloSelezionato = newValue;
              });
            },
            validator: (value) 
            {
              if (value == null) 
              {
                return 'Seleziona un ruolo';
              }
              return null;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () 
          {
            Navigator.of(context).pop();
          },
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: _ruoloSelezionato != null ? () => _cambiaRuolo(context) : null,
          child: const Text('Conferma'),
        ),
      ],
    );
  }

  Future<void> _cambiaRuolo(BuildContext context) async 
  {
    final viewModel = context.read<UtenteViewModel>();
    final navigator = Navigator.of(context);

    final success = await viewModel.cambiaRuoloUtente(
      id: widget.utenteId,
      nuovoRuolo: _ruoloSelezionato!,
    );

    if (success) 
    {
      // Mostra un messaggio di successo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ruolo cambiato a ${_ruoloSelezionato!}'),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pop(); // Chiudi il dialog
    } 
    else 
    {
      // Mostra un messaggio di errore (già gestito dal ViewModel)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore nel cambio ruolo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}