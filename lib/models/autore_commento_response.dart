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
}