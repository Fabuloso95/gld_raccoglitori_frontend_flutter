import 'package:gld_raccoglitori/models/UtenteRequestModel.dart';

class UtenteUpdateRequestModel
{
  final String? username;
  final String? nome;
  final String? cognome;
  final String email;
  final Ruolo ruolo;
  final String? telefono;
  final DateTime? dataNascita;

  UtenteUpdateRequestModel({
    this.username,
    this.nome,
    this.cognome,
    required this.email,
    required this.ruolo,
    this.telefono,
    this.dataNascita
  });

  factory UtenteUpdateRequestModel.fromJson(Map<String, dynamic> json) 
  {
    return UtenteUpdateRequestModel(
      username: json['username'],
      nome: json['nome'],
      cognome: json['cognome'],
      email: json['email'],
      ruolo: Ruolo.values.firstWhere(
        (e) => e.toString().split('.').last == json['ruolo'],),

      telefono: json['telefono'],
      dataNascita: json['dataNascita'],
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'username': username,
      'nome': nome,
      'cognome': cognome,
      'email': email,
      'ruolo': ruolo.toString().split('.').last,
      'telefono': telefono,
      'dataNascita': dataNascita,
    };
  }
}