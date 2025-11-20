import 'autore_commento_response.dart';

class MessaggioChatResponse 
{
  final int id;
  final AutoreCommentoResponse mittente;
  final AutoreCommentoResponse? destinatario;
  final String? gruppoId;
  final String tipoChat;
  final String contenuto;
  final DateTime dataInvio;

  MessaggioChatResponse({
    required this.id,
    required this.mittente,
    required this.destinatario,
    required this.gruppoId,
    required this.tipoChat,
    required this.contenuto,
    required this.dataInvio,
  });

  factory MessaggioChatResponse.fromJson(Map<String, dynamic> json) 
  {
    try 
    {
      print('🔍 MessaggioChatResponse - JSON ricevuto: $json');
      
      final mittenteMap = json['mittente'] as Map<String, dynamic>;
      final mittente = AutoreCommentoResponse.fromJson(mittenteMap);
      
      AutoreCommentoResponse? destinatario;
      if (json['destinatario'] != null) 
      {
        final destinatarioMap = json['destinatario'] as Map<String, dynamic>;
        destinatario = AutoreCommentoResponse.fromJson(destinatarioMap);
      }
      
      return MessaggioChatResponse(
        id: (json['id'] as num).toInt(),
        mittente: mittente,
        destinatario: destinatario,
        gruppoId: json['gruppoId']?.toString(),
        tipoChat: json['tipoChat'].toString(),
        contenuto: json['contenuto'].toString(),
        dataInvio: DateTime.parse(json['dataInvio'].toString()),
      );
    } 
    catch (e) 
    {
      print('❌ Errore in MessaggioChatResponse.fromJson: $e');
      print('❌ JSON che ha causato l\'errore: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() 
  {
    return {
      'id': id,
      'mittente': mittente,
      'destinatario': destinatario,
      'gruppoId': gruppoId,
      'tipoChat': tipoChat,
      'contenuto': contenuto,
      'dataInvio': dataInvio.toIso8601String(),
    };
  }
}