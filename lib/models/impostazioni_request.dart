class ImpostazioniRequest 
{
  final bool? notificheEmail;
  final bool? notifichePush;
  final String? lingua;
  final String? tema;
  final bool? emailRiassuntoSettimanale;
  final bool? privacyProfiloPubblico;

  ImpostazioniRequest({
    this.notificheEmail,
    this.notifichePush,
    this.lingua,
    this.tema,
    this.emailRiassuntoSettimanale,
    this.privacyProfiloPubblico,
  });

  Map<String, dynamic> toJson() 
  {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (notificheEmail != null) data['notificheEmail'] = notificheEmail;
    if (notifichePush != null) data['notifichePush'] = notifichePush;
    if (lingua != null) data['lingua'] = lingua;
    if (tema != null) data['tema'] = tema;
    if (emailRiassuntoSettimanale != null) data['emailRiassuntoSettimanale'] = emailRiassuntoSettimanale;
    if (privacyProfiloPubblico != null) data['privacyProfiloPubblico'] = privacyProfiloPubblico;
    return data;
  }
}