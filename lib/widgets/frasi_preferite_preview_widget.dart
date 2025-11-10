import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/frase_preferita_view_model.dart';
import 'package:gld_raccoglitori/widgets/salva_frase_dialog.dart';
import '../models/frase_preferita_response.dart';

class FrasiPreferitePreviewWidget extends StatelessWidget 
{
  final int libroId;
  final String? titoloLibro;

  const FrasiPreferitePreviewWidget({
    super.key,
    required this.libroId,
    this.titoloLibro,
  });

  @override
  Widget build(BuildContext context) 
  {
    return Consumer<FrasePreferitaViewModel>(
      builder: (context, viewModel, child) 
      {
        final frasi = viewModel.getFrasiPerLibro(libroId);

        // Carica le frasi quando il widget viene costruito
        if (frasi.isEmpty && !viewModel.isLoading) 
        {
          WidgetsBinding.instance.addPostFrameCallback((_) 
          {
            viewModel.caricaFrasiPerLibro(libroId);
          });
        }

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
                        // Naviga alla lista completa
                        Navigator.pushNamed(
                          context,
                          '/frasi-preferite',
                          arguments: 
                          {
                            'libroId': libroId,
                            'titoloLibro': titoloLibro,
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
                        builder: (context) => SalvaFraseDialog(
                          libroId: libroId,
                          titoloLibro: titoloLibro,
                        ),
                      );
                    },
                    tooltip: 'Aggiungi frase',
                  ),
                ],
              ),
            ),
            if (frasi.isNotEmpty)
              ...frasi.take(2).map((frase) => _FrasePreviewItem(frase: frase)),
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