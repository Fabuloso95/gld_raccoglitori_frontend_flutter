import 'libro_response.dart';

class PropostaVotoResponse 
{
  final int id;
  final LibroResponse libroProposto;
  final String meseVotazione;
  final DateTime dataCreazione;
  final int numVoti;

  PropostaVotoResponse({
    required this.id,
    required this.libroProposto,
    required this.meseVotazione,
    required this.dataCreazione,
    required this.numVoti,
  });

  factory PropostaVotoResponse.fromJson(Map<String, dynamic> json) 
  {
    return PropostaVotoResponse(
      id: (json['id'] as int).toInt(),
      libroProposto: json['libroProposto'] as LibroResponse,
      meseVotazione: json['meseVotazione'] as String,
      dataCreazione: DateTime.parse(json['dataCreazione'] as String),
      numVoti: (json['numVoti'] as int).toInt(),
    );
  }
}