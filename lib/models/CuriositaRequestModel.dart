class CuriositaRequestModel
{
  final int libroId;
  final String titolo;
  final String contenuto;
  final int paginaRiferimento;

  CuriositaRequestModel({
    required this.libroId,
    required this.titolo,
    required this.contenuto,
    required this.paginaRiferimento
  });

  factory CuriositaRequestModel.fromJson(Map<String, dynamic> json) 
  {
    return CuriositaRequestModel(
      libroId: (json['libroId'] as num).toInt(),
      titolo: json['titolo'],
      contenuto: json['contenuto'],
      paginaRiferimento: (json['paginaRiferimento'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson()
  {
    return 
    {
      'libroId': libroId,
      'titolo': titolo,
      'contenuto': contenuto,
      'paginaRiferimento': paginaRiferimento,
    };
  }
}