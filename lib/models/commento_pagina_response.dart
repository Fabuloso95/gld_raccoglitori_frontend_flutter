class CommentoPaginaResponse 
{
  final int id;
  final String contenuto;
  final int letturaCorrenteId;
  final int paginaRiferimento;
  final int utente;
  final DateTime dataCreazione;

  CommentoPaginaResponse({
    required this.id,
    required this.contenuto,
    required this.letturaCorrenteId,
    required this.paginaRiferimento,
    required this.utente,
    required this.dataCreazione,
  });

  factory CommentoPaginaResponse.fromJson(Map<String, dynamic> json) 
  {
    return CommentoPaginaResponse(
      id: json['id'],
      contenuto: json['contenuto'],
      letturaCorrenteId: json['letturaCorrenteId'],
      paginaRiferimento: json['paginaRiferimento'],
      utente: json['utente'],
      dataCreazione: DateTime.parse(json['dataCreazione']), 
    );
  }
}