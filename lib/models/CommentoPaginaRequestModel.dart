class CommentoPaginaRequestModel
{
  final int letturaCorrenteId;
  final int paginaRiferimento;
  final String contenuto;

  CommentoPaginaRequestModel({
    required this.letturaCorrenteId,
    required this.paginaRiferimento,
    required this.contenuto
  });

  factory CommentoPaginaRequestModel.fromJson(Map<String, dynamic> json) 
  {
    return CommentoPaginaRequestModel(
      letturaCorrenteId: (json['letturaCorrenteId'] as num).toInt(),
      paginaRiferimento: (json['paginaRiferimento'] as num).toInt(),
      contenuto: json['contenuto'],
    );
  }

  Map<String, dynamic> toJson()
  {
    return 
    {
      'letturaCorrenteId': letturaCorrenteId,
      'paginaRiferimento': paginaRiferimento,
      'contenuto': contenuto
    };
  }
}