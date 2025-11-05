class PropostaVotoResponse 
{
  final int id;
  final String nome;

  PropostaVotoResponse({
    required this.id,
    required this.nome,
  });

  factory PropostaVotoResponse.fromJson(Map<String, dynamic> json) 
  {
    return PropostaVotoResponse(
      id: (json['id'] as int).toInt(),
      nome: json['nome'] as String,
    );
  }
}