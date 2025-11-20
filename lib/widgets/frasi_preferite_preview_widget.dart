import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/frase_preferita_view_model.dart';
import '../models/frase_preferita_response.dart';
import 'aggiungi_frase_preferita_dialog.dart';

class FrasiPreferitePreviewWidget extends StatefulWidget 
{
  final int libroId;
  final String? titoloLibro;

  const FrasiPreferitePreviewWidget({
    super.key,
    required this.libroId,
    this.titoloLibro,
  });

  @override
  State<FrasiPreferitePreviewWidget> createState() => _FrasiPreferitePreviewWidgetState();
}

class _FrasiPreferitePreviewWidgetState extends State<FrasiPreferitePreviewWidget> 
{
  bool _hasLoaded = false;

  @override
  void initState() 
  {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) 
    {
      if (!_hasLoaded) 
      {
        context.read<FrasePreferitaViewModel>().caricaFrasiPerLibro(widget.libroId);
        _hasLoaded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) 
  {
    return Consumer<FrasePreferitaViewModel>(
      builder: (context, viewModel, child) 
      {
        final frasi = viewModel.frasiLibro;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.format_quote, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Frasi Preferite (${frasi.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  if (frasi.isNotEmpty)
                    TextButton(
                      onPressed: () 
                      {
                        Navigator.pushNamed(
                          context,
                          '/frasi-preferite',
                          arguments: 
                          {
                            'libroId': widget.libroId,
                            'titoloLibro': widget.titoloLibro,
                          },
                        );
                      },
                      child: const Text('Vedi tutte'),
                    ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: () 
                    {
                      showDialog(
                        context: context,
                        builder: (context) => AggiungiFrasePreferitaDialog(
                          libroId: widget.libroId,
                          numeroPagineTotali: 1000,
                        ),
                      ).then((success) {
                        if (success == true) {
                          // Ricarica le frasi
                          context.read<FrasePreferitaViewModel>().caricaFrasiPerLibro(widget.libroId);
                        }
                      });
                    },
                    tooltip: 'Aggiungi frase',
                  ),
                ],
              ),
            ),
            if (frasi.isNotEmpty)
              ...frasi.take(2).map((frase) => _FrasePreviewItem(frase: frase)),
            if (frasi.isEmpty && !viewModel.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Nessuna frase preferita ancora',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FrasePreviewItem extends StatelessWidget 
{
  final FrasePreferitaResponse frase;

  const _FrasePreviewItem({required this.frase});

  @override
  Widget build(BuildContext context) 
  {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${frase.testoFrase}"',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (frase.paginaRiferimento > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Pagina ${frase.paginaRiferimento}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}