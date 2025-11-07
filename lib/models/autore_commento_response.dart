class AutoreCommentoResponse 
{
  final int id;
  final String username;

  AutoreCommentoResponse({
    required this.id,
    required this.username
  });

  factory AutoreCommentoResponse.fromJson(Map<String, dynamic> json) 
  {
    return AutoreCommentoResponse(
      id: (json['id'] as int).toInt(),
      username: json['username']
    );
  }

  String get nomeVisualizzato 
  {
    return username;
  }

  String get iniziale 
  {
    return username.isNotEmpty ? username[0].toUpperCase() : '?';
  }
}