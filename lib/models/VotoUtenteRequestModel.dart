class VotoUtenteRequestModel
{
  final int propostaVotoId;
  final String meseVotazione;

  VotoUtenteRequestModel({
    required this.propostaVotoId,
    required this.meseVotazione
  });

  factory VotoUtenteRequestModel.fromJson(Map<String, dynamic> json) 
  {
    return VotoUtenteRequestModel(
      propostaVotoId: json['propostaVotoId'] as int,
      meseVotazione: json['meseVotazione'],
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'propostaVotoId': propostaVotoId,
      'meseVotazione': meseVotazione
    };
  }
}