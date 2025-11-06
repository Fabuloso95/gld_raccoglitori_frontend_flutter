class MessaggioChatRequestModel
{
  final String? gruppoId;
  final String tipoChat;
  final int? destinatarioId;
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
      gruppoId: json['gruppoId'] as String?,
      tipoChat: json['tipoChat'] as String,
      destinatarioId: json['destinatarioId'] as int?,
      contenuto: json['contenuto'] as String,
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      if (gruppoId != null) 'gruppoId': gruppoId,
      'tipoChat': tipoChat,
      if (destinatarioId != null) 'destinatarioId': destinatarioId,
      'contenuto': contenuto
    };
  }
}