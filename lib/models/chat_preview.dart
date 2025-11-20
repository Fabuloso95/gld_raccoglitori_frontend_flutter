class ChatPreview 
{
  final String? gruppoId;
  final int? altroUtenteId;
  final String tipoChat;
  final String titolo;
  final String? ultimoMessaggio;
  final DateTime? dataUltimoMessaggio;
  final int messaggiNonLetti;

  ChatPreview({
    this.gruppoId,
    this.altroUtenteId,
    required this.tipoChat,
    required this.titolo,
    this.ultimoMessaggio,
    this.dataUltimoMessaggio,
    required this.messaggiNonLetti,
  });
}