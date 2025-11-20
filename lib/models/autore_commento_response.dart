class AutoreCommentoResponse 
{
  final int id;
  final String username;
  final String? nome;
  final String? cognome;

  AutoreCommentoResponse({
    required this.id,
    required this.username,
    required this.nome,
    required this.cognome
  });

  factory AutoreCommentoResponse.fromJson(Map<String, dynamic> json) 
  {
    print('🔍 AutoreCommentoResponse - JSON ricevuto: $json');
    print('🔍 Tipo di id: ${json['id'].runtimeType}');
    return AutoreCommentoResponse(
      id: (json['id'] as num).toInt(),
      username: json['username'],
      nome: json['nome'] as String?,
      cognome: json['cognome'] as String?,
    );
  }

  String get nomeVisualizzato 
  {
    return username;
  }

  String get iniziale 
  {
    if (nome != null && nome!.isNotEmpty) 
    {
      return nome!.substring(0, 1).toUpperCase();
    }
    return username.substring(0, 1).toUpperCase();
  }
}