import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/proposta_voto_view_model.dart';
import 'package:gld_raccoglitori/models/proposta_voto_response.dart';

class PropostaVotoCard extends StatelessWidget {
  final PropostaVotoResponse proposta;

  const PropostaVotoCard({
    super.key,
    required this.proposta,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<PropostaVotoViewModel>();
    final haVotato = viewModel.haVotatoPerProposta(proposta.id);
    final puoVotare = viewModel.votiUtenteCorrente < viewModel.maxVotiConsentiti;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con info libro
            Row(
              children: [
                // Copertina
                Container(
                  width: 60,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: proposta.libroProposto.copertinaUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(proposta.libroProposto.copertinaUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: proposta.libroProposto.copertinaUrl.isEmpty 
                        ? Colors.grey[200] 
                        : null,
                  ),
                  child: proposta.libroProposto.copertinaUrl.isEmpty
                      ? const Icon(Icons.book, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),
                
                // Info libro
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proposta.libroProposto.titolo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        proposta.libroProposto.autore,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.how_to_vote, size: 16, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            '${proposta.numVoti} ${proposta.numVoti == 1 ? 'voto' : 'voti'}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Azioni
            Row(
              children: [
                // Bottone Vota/Rimuovi Voto
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: haVotato
                        ? () => _rimuoviVoto(context, proposta.id)
                        : (puoVotare ? () => _votaProposta(context, proposta.id) : null),
                    icon: Icon(haVotato ? Icons.check : Icons.how_to_vote),
                    label: Text(haVotato ? 'Votato' : 'Vota'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: haVotato ? Colors.green : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Bottone Dettagli
                OutlinedButton(
                  onPressed: () => _mostraDettagliLibro(context, proposta.libroProposto.id),
                  child: const Text('Dettagli'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _votaProposta(BuildContext context, int propostaId) async {
    final viewModel = context.read<PropostaVotoViewModel>();
    final success = await viewModel.votaPerProposta(propostaId);
    
    if (success) {
      // Non serve controllare mounted in StatelessWidget
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voto registrato con successo!')),
      );
    }
  }

  void _rimuoviVoto(BuildContext context, int propostaId) async {
    final viewModel = context.read<PropostaVotoViewModel>();
    final success = await viewModel.rimuoviVoto(propostaId);
    
    if (success) {
      // Non serve controllare mounted in StatelessWidget
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voto rimosso con successo!')),
      );
    }
  }

  void _mostraDettagliLibro(BuildContext context, int libroId) {
    Navigator.pushNamed(
      context,
      '/dettaglio-libro',
      arguments: {'libroId': libroId},
    );
  }
}