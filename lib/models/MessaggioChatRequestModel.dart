import 'package:uuid/uuid.dart';

class MessaggioChatRequestModel
{
  final Uuid gruppoId;
  final String tipoChat;
  final int destinatarioId;
  final String contenuto;

  MessaggioChatRequestModel({
    required this.gruppoId,
    required this.tipoChat,
    required this.destinatarioId,
    required this.contenuto
  });

  factory MessaggioChatRequestModel.fromJson(Map<String, dynamic> json)
  {
    return MessaggioChatRequestModel(
      gruppoId: json['gruppoId'] as Uuid,
      tipoChat: json['tipoChat'] as String,
      destinatarioId: (json['destinatarioId'] as int).toInt(),
      contenuto: json['contenuto'] as String,
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'gruppoId': gruppoId,
      'tipoChat': tipoChat,
      'destinatarioId': destinatarioId,
      'contenuto': contenuto
    };
  }
}