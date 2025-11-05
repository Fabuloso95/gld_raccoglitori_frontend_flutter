import 'package:uuid/uuid.dart';
import 'autore_commento_response.dart';

class MessaggioChatResponse 
{
  final int id;
  final AutoreCommentoResponse titolo;
  final AutoreCommentoResponse destinatario;
  final Uuid gruppoID;
  final String tipoChat;
  final String contenuto;
  final DateTime dataInvio;

  MessaggioChatResponse({
    required this.id,
    required this.titolo,
    required this.destinatario,
    required this.gruppoID,
    required this.tipoChat,
    required this.contenuto,
    required this.dataInvio,
  });

  factory MessaggioChatResponse.fromJson(Map<String, dynamic> json) 
  {
    return MessaggioChatResponse(
      id: (json['id'] as int).toInt(),
      titolo: json['titolo'] as AutoreCommentoResponse,
      destinatario: json['destinatario'] as AutoreCommentoResponse,
      gruppoID: json['gruppoID'] as Uuid,
      tipoChat: json['tipoChat'] as String,
      contenuto: json['contenuto'] as String,
      dataInvio: DateTime.parse(json['dataInvio'] as String),
    );
  }
}