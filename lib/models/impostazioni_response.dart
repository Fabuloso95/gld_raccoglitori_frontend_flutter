class ImpostazioniResponse 
{
  final int id;
  final int utenteId;
  final bool notificheEmail;
  final bool notifichePush;
  final String lingua;
  final String tema;
  final bool emailRiassuntoSettimanale;
  final bool privacyProfiloPubblico;
  final DateTime dataAggiornamento;

  ImpostazioniResponse({
    required this.id,
    required this.utenteId,
    required this.notificheEmail,
    required this.notifichePush,
    required this.lingua,
    required this.tema,
    required this.emailRiassuntoSettimanale,
    required this.privacyProfiloPubblico,
    required this.dataAggiornamento,
  });

  factory ImpostazioniResponse.fromJson(Map<String, dynamic> json) 
  {
    return ImpostazioniResponse(
      id: json['id'] as int,
      utenteId: json['utenteId'] as int,
      notificheEmail: json['notificheEmail'] as bool,
      notifichePush: json['notifichePush'] as bool,
      lingua: json['lingua'] as String,
      tema: json['tema'] as String,
      emailRiassuntoSettimanale: json['emailRiassuntoSettimanale'] as bool,
      privacyProfiloPubblico: json['privacyProfiloPubblico'] as bool,
      dataAggiornamento: DateTime.parse(json['dataAggiornamento'] as String),
    );
  }

  Map<String, dynamic> toJson() 
  {
    return 
    {
      'id': id,
      'utenteId': utenteId,
      'notificheEmail': notificheEmail,
      'notifichePush': notifichePush,
      'lingua': lingua,
      'tema': tema,
      'emailRiassuntoSettimanale': emailRiassuntoSettimanale,
      'privacyProfiloPubblico': privacyProfiloPubblico,
      'dataAggiornamento': dataAggiornamento.toIso8601String(),
    };
  }
}