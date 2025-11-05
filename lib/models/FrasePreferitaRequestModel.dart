class FrasePreferitaRequestModel
{
  final int utenteId;
  final int libroId;
  final String testoFrase;
  final int paginaRiferimento;

  FrasePreferitaRequestModel({
    required this.utenteId,
    required this.libroId,
    required this.testoFrase,
    required this.paginaRiferimento
  });

  factory FrasePreferitaRequestModel.fromJson(Map<String, dynamic> json) 
  {
    return FrasePreferitaRequestModel(
      utenteId: (json['utenteId'] as num).toInt(),
      libroId: (json['libroId'] as num).toInt(),
      testoFrase: json['testoFrase'],
      paginaRiferimento: (json['paginaRiferimento'] as num).toInt()
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'utenteId': utenteId,
      'libroId': libroId,
      'testoFrase': testoFrase,
      'paginaRiferimento': paginaRiferimento,
    };
  }
}