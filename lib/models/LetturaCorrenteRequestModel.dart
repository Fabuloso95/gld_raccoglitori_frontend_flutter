class LetturaCorrenteRequestModel
{
  final int libroId;
  final int paginaIniziale;

  LetturaCorrenteRequestModel({
    required this.libroId,
    required this.paginaIniziale
  });

  factory LetturaCorrenteRequestModel.fromJson(Map<String, dynamic> json) 
  {
    return LetturaCorrenteRequestModel(
      libroId: (json['libroId'] as num).toInt(),
      paginaIniziale: (json['paginaIniziale'] as num).toInt()
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'libroId': libroId,
      'paginaIniziale': paginaIniziale
    };
  }
}