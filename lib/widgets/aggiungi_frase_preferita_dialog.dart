import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/frase_preferita_view_model.dart';
import 'package:gld_raccoglitori/services/auth_service.dart';

class AggiungiFrasePreferitaDialog extends StatefulWidget 
{
  final int libroId;
  final int numeroPagineTotali;
  final int? paginaPrecompilata;
  final String? testoPrecompilato;

  const AggiungiFrasePreferitaDialog({
    super.key,
    required this.libroId,
    required this.numeroPagineTotali,
    this.paginaPrecompilata,
    this.testoPrecompilato,
  });

  @override
  State<AggiungiFrasePreferitaDialog> createState() => _AggiungiFrasePreferitaDialogState();
}

class _AggiungiFrasePreferitaDialogState extends State<AggiungiFrasePreferitaDialog> 
{
  final _formKey = GlobalKey<FormState>();
  final _testoController = TextEditingController();
  final _paginaController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() 
  {
    super.initState();
    
    // Precompila se disponibile
    if (widget.testoPrecompilato != null) 
    {
      _testoController.text = widget.testoPrecompilato!;
    }
    
    if (widget.paginaPrecompilata != null) 
    {
      _paginaController.text = widget.paginaPrecompilata!.toString();
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.format_quote, color: Colors.blue),
          SizedBox(width: 8),
          Text('Aggiungi Frase Preferita'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _testoController,
                decoration: const InputDecoration(
                  labelText: 'Testo della frase *',
                  border: OutlineInputBorder(),
                  hintText: 'Inserisci la frase che ti è piaciuta...',
                ),
                maxLines: 4,
                validator: (value) 
                {
                  if (value == null || value.trim().isEmpty) 
                  {
                    return 'Inserisci il testo della frase';
                  }
                  if (value.trim().length < 3) {
                    return 'La frase deve essere di almeno 3 caratteri';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _paginaController,
                decoration: InputDecoration(
                  labelText: 'Pagina (opzionale)',
                  border: const OutlineInputBorder(),
                  hintText: 'Numero pagina (1-${widget.numeroPagineTotali})',
                  suffixText: 'di ${widget.numeroPagineTotali}',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) 
                  {
                    return null;
                  }
                  
                  final pagina = int.tryParse(value);
                  if (pagina == null) 
                  {
                    return 'Inserisci un numero valido';
                  }
                  if (pagina < 1 || pagina > widget.numeroPagineTotali) 
                  {
                    return 'Pagina deve essere tra 1 e ${widget.numeroPagineTotali}';
                  }
                  return null;
                },
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
          onPressed: _isLoading ? null : () => Navigator.pop(context),
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
              : const Text('Salva Frase'),
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
      final viewModel = context.read<FrasePreferitaViewModel>();
      final authService = context.read<AuthService>();
      final utenteId = authService.currentUserId;
      
      if (utenteId == null) 
      {
        throw Exception('Utente non autenticato');
      }

      print('🎯 SALVANDO FRASE:');
      print('  - Libro ID: ${widget.libroId}');
      print('  - Testo: ${_testoController.text.trim()}');
      print('  - Pagina: ${_paginaController.text.isNotEmpty ? int.parse(_paginaController.text.trim()) : 0}');
      print('  - Utente ID: $utenteId');

      final success = await viewModel.salvaFraseRapida(
        utenteId: utenteId,
        libroId: widget.libroId,
        testoFrase: _testoController.text.trim(),
        paginaRiferimento: _paginaController.text.isNotEmpty 
            ? int.parse(_paginaController.text.trim()) 
            : 0,
      );

      if (success && mounted) 
      {
        print('✅ Frase salvata con successo!');
        
        WidgetsBinding.instance.addPostFrameCallback((_) 
        {
          Navigator.pop(context, true);
        });
        
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
      print('❌ ERRORE nel salvataggio: $e');
      if (mounted) 
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() 
  {
    _testoController.dispose();
    _paginaController.dispose();
    super.dispose();
  }
}