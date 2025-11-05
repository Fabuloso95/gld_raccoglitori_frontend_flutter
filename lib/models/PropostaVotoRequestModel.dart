class PropostaVotoRequestModel
{
  final int libroId;
  final String meseVotazione;

  PropostaVotoRequestModel({
    required this.libroId,
    required this.meseVotazione
  });

    factory PropostaVotoRequestModel.fromJson(Map<String, dynamic> json) 
  {
    return PropostaVotoRequestModel(
      libroId: (json['libroId'] as num).toInt(),
      meseVotazione: json['meseVotazione'],
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'libroId': libroId,
      'meseVotazione': meseVotazione
    };
  }
}