class FrasePreferitaResponse 
{
  final int id;
  final int utenteId;
  final int libroId;
  final String testoFrase;
  final int paginaRiferimento;

  FrasePreferitaResponse({
    required this.id,
    required this.utenteId,
    required this.libroId,
    required this.testoFrase,
    required this.paginaRiferimento
  });

  factory FrasePreferitaResponse.fromJson(Map<String, dynamic> json) 
  {
    return FrasePreferitaResponse(
      id: (json['id'] as int).toInt(),
      utenteId: (json['utenteId'] as int).toInt(),
      libroId: (json['libroId'] as int).toInt(),
      testoFrase: json['testoFrase'] as String,
      paginaRiferimento: (json['paginaRiferimento'] as int).toInt(),
    );
  }
}