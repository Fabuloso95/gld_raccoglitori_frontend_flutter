class RuoloResponse 
{
  final int id;
  final String nome;

  RuoloResponse({
    required this.id,
    required this.nome,
  });

  factory RuoloResponse.fromJson(Map<String, dynamic> json) 
  {
    return RuoloResponse(
      id: (json['id'] as int).toInt(),
      nome: json['nome'] as String,
    );
  }
}