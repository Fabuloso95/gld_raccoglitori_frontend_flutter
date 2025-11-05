class RegistrazionerequestModel 
{
  final String username;
  final String email;
  final String password;
  final String nome;
  final String cognome;

  RegistrazionerequestModel(
  {
    required this.username,
    required this.email,
    required this.password,
    required this.nome,
    required this.cognome
  });

  factory RegistrazionerequestModel.fromJson(Map<String, dynamic> json) 
  {
    return RegistrazionerequestModel(
      username: json['username'],
      email: json['email'],
      password: json['password'],
      nome: json['nome'],
      cognome: json['cognome'],
    );
  }

  Map<String, dynamic> toJson() 
  {
    return 
    {
      'username': username,
      'email': email,
      'password': password,
      'nome': nome,
      'cognome': cognome
    };
  }
}