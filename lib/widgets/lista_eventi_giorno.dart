import 'package:flutter/material.dart';
import 'package:gld_raccoglitori/models/EventoRequest.dart';
import 'package:provider/provider.dart';
import '../models/EventoResponse.dart';
import '../view_models/evento_view_model.dart';

class ListaEventiGiorno extends StatelessWidget 
{
  final DateTime selectedDate;

  const ListaEventiGiorno({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) 
  {
    final viewModel = context.watch<EventoViewModel>();
    final eventiDelGiorno = viewModel.getEventiDelGiorno(selectedDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Eventi del ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (eventiDelGiorno.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'Nessun evento per oggi',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: eventiDelGiorno.length,
                itemBuilder: (context, index) {
                  final evento = eventiDelGiorno[index];
                  return _buildEventoCard(evento);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventoCard(EventoResponse evento) 
  {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          width: 4,
          decoration: BoxDecoration(
            color: evento.tipoEvento.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          evento.titolo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              evento.formattedDateRange,
              style: const TextStyle(fontSize: 12),
            ),
            if (evento.descrizione.isNotEmpty)
              Text(
                evento.descrizione,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: Text(
          evento.tipoEvento.emoji,
          style: const TextStyle(fontSize: 16),
        ),
        onTap: () {
          // Mostra dettagli evento
        },
      ),
    );
  }
}