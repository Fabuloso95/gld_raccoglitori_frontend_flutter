import 'autore_commento_response.dart';

class MessaggioChatResponse 
{
  final int id;
  final AutoreCommentoResponse mittente;
  final AutoreCommentoResponse? destinatario;
  final String? gruppoID;
  final String tipoChat;
  final String contenuto;
  final DateTime dataInvio;

  MessaggioChatResponse({
    required this.id,
    required this.mittente,
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
      mittente: json['mittente'] as AutoreCommentoResponse,
      destinatario: json['destinatario'] != null ? AutoreCommentoResponse.fromJson(json['destinatario']) : null,
      gruppoID: json['gruppoID'] as String?,
      tipoChat: json['tipoChat'] as String,
      contenuto: json['contenuto'] as String,
      dataInvio: DateTime.parse(json['dataInvio'] as String),
    );
  }
}