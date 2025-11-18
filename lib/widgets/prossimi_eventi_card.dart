import 'package:flutter/material.dart';
import 'package:gld_raccoglitori/models/EventoRequest.dart';
import 'package:provider/provider.dart';
import '../models/EventoResponse.dart';
import '../view_models/evento_view_model.dart';

class ProssimiEventiCard extends StatelessWidget 
{
  const ProssimiEventiCard({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final viewModel = context.watch<EventoViewModel>();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Prossimi Eventi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (viewModel.prossimaVotazione != null || viewModel.prossimaDiscussione != null)
            Row(
              children: [
                if (viewModel.prossimaVotazione != null)
                  Expanded(child: _buildEventoMiniCard(viewModel.prossimaVotazione!)),
                if (viewModel.prossimaDiscussione != null)
                  Expanded(child: _buildEventoMiniCard(viewModel.prossimaDiscussione!)),
              ],
            )
          else
            const Text(
              'Nessun evento in programma',
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildEventoMiniCard(EventoResponse evento) 
  {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: evento.tipoEvento.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    evento.tipoEvento.displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(evento.tipoEvento.emoji),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              evento.titolo,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${evento.dataInizio.day}/${evento.dataInizio.month} ${evento.dataInizio.hour.toString().padLeft(2, '0')}:${evento.dataInizio.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}