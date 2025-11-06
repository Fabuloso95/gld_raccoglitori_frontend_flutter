enum Ruolo 
{
  USER,
  ADMIN
}

class UtenteRequestModel 
{
  final String username;
  final String nome;
  final String cognome;
  final String? password;
  final String email;
  final String ruolo;

  UtenteRequestModel({
    required this.username,
    required this.nome,
    required this.cognome,
    this.password,
    required this.email,
    required this.ruolo,
  });

  factory UtenteRequestModel.fromJson(Map<String, dynamic> json) 
  {
    return UtenteRequestModel(
      username: json['username'] as String,
      nome: json['nome'] as String,
      cognome: json['cognome'] as String,
      password: json['password'] as String?,
      email: json['email'] as String,
      ruolo: json['ruolo'] as String,
    );
  }

  Map<String, dynamic> toJson() 
  {
    return 
    {
      'username': username,
      'nome': nome,
      'cognome': cognome,
      if (password != null) 'password': password,
      'email': email,
      'ruolo': ruolo,
    };
  }
}