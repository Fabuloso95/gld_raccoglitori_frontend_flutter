import 'ruolo_response.dart';

class UtenteResponse 
{
  final int id;
  final String username;
  final String email;
  final String nome;
  final String cognome;
  final RuoloResponse ruolo;
  final DateTime dataRegistrazione;
  final bool attivo;

  UtenteResponse({
    required this.id,
    required this.username,
    required this.email,
    required this.nome,
    required this.cognome,
    required this.ruolo,
    required this.dataRegistrazione,
    required this.attivo,
  });

  factory UtenteResponse.fromJson(Map<String, dynamic> json) 
  {
    return UtenteResponse(
      id: (json['id'] as int).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      nome: json['nome'] as String,
      cognome: json['cognome'] as String,
      ruolo: RuoloResponse.fromJson(json['ruolo']),
      dataRegistrazione: DateTime.parse(json['dataRegistrazione'] as String),
      attivo: json['attivo'] as bool,
    );
  }
}