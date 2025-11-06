class VotoUtenteResponse 
{
  final int id;
  final int utenteId;
  final int propostaVotoId;
  final String meseVotazione;

  VotoUtenteResponse({
    required this.id,
    required this.utenteId,
    required this.propostaVotoId,
    required this.meseVotazione,
  });

  factory VotoUtenteResponse.fromJson(Map<String, dynamic> json) 
  {
    return VotoUtenteResponse(
      id: json['id'] as int,
      utenteId: json['utenteId'] as int,
      propostaVotoId: (json['propostaVotoId'] as int).toInt(),
      meseVotazione: json['meseVotazione'] as String,
    );
  }
}