import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/frase_preferita_view_model.dart';
import 'package:gld_raccoglitori/services/auth_service.dart';

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
  bool _isLoading = false;

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
      title: const Row(
        children: [
          Icon(Icons.format_quote, color: Colors.blue),
          SizedBox(width: 8),
          Text('Salva Frase Preferita'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.titoloLibro != null) ...[
                Text(
                  'Da: ${widget.titoloLibro}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              TextFormField(
                controller: _testoFraseController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Testo della frase *',
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
              const SizedBox(height: 8),
              Text(
                '* Campo obbligatorio',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _salvaFrase,
          child: _isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Salva'),
        ),
      ],
    );
  }

  Future<void> _salvaFrase() async 
  {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try 
    {
      final authService = context.read<AuthService>();
      final viewModel = context.read<FrasePreferitaViewModel>();
      final utenteId = authService.currentUserId;

      if (utenteId == null) 
      {
        throw Exception('Devi essere loggato per salvare frasi preferite');
      }

      if (viewModel.fraseEsisteGia(_testoFraseController.text.trim(), widget.libroId)) 
      {
        throw Exception('Hai già salvato questa frase!');
      }

      final success = await viewModel.salvaFraseRapida(
        utenteId: utenteId,
        libroId: widget.libroId,
        testoFrase: _testoFraseController.text.trim(),
        paginaRiferimento: int.tryParse(_paginaController.text) ?? 0,
      );

      if (success && mounted) 
      {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Frase salvata con successo!'),
            backgroundColor: Colors.green,
          ),
        );
      }
       else 
      {
        throw Exception('Errore nel salvataggio della frase');
      }
    } 
    catch (e) 
    {
      if (mounted) 
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } 
    finally 
    {
      if (mounted) 
      {
        setState(() => _isLoading = false);
      }
    }
  }
}