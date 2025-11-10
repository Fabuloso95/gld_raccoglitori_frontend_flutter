import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/curiosita_view_model.dart';
import '../models/curiosita_response.dart';

class CuriositaPreviewWidget extends StatelessWidget 
{
  final int libroId;
  final int? paginaRiferimento;

  const CuriositaPreviewWidget({
    super.key,
    required this.libroId,
    this.paginaRiferimento,
  });

  @override
  Widget build(BuildContext context) 
  {
    return Consumer<CuriositaViewModel>(
      builder: (context, viewModel, child) 
      {
        final curiosita = paginaRiferimento != null ? viewModel.curiositaPagina : viewModel.curiositaLibro;

        // Carica le curiosità quando il widget viene costruito
        if (curiosita.isEmpty && !viewModel.isLoading) 
        {
          WidgetsBinding.instance.addPostFrameCallback((_) 
          {
            if (paginaRiferimento != null) 
            {
              viewModel.caricaCuriositaPerPagina(
                libroId: libroId,
                paginaRiferimento: paginaRiferimento!,
              );
            } 
            else 
            {
              viewModel.caricaCuriositaPerLibro(libroId);
            }
          });
        }

        if (curiosita.isEmpty) 
        {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Curiosità (${curiosita.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () 
                    {
                      Navigator.pushNamed(
                        context,
                        '/curiosita',
                        arguments: 
                        {
                          'libroId': libroId,
                          'paginaRiferimento': paginaRiferimento,
                        },
                      );
                    },
                    child: const Text('Vedi tutte'),
                  ),
                ],
              ),
            ),
            ...curiosita.take(2).map((curiosita) => 
              _CuriositaPreviewItem(curiosita: curiosita)
            ),
          ],
        );
      },
    );
  }
}

class _CuriositaPreviewItem extends StatelessWidget 
{
  final CuriositaResponse curiosita;

  const _CuriositaPreviewItem({required this.curiosita});

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
              curiosita.titolo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              curiosita.contenuto,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}