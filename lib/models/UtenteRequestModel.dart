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
  final Ruolo ruolo;

  UtenteRequestModel({
    required this.username,
    required this.nome,
    required this.cognome,
    this.password,
    required this.email,
    required this.ruolo
  });

  factory UtenteRequestModel.fromJson(Map<String, dynamic> json) 
  {
    return UtenteRequestModel(
      username: json['username'],
      nome: json['nome'],
      cognome: json['cognome'],
      password: json['password'],
      email: json['email'],
      ruolo: Ruolo.values.firstWhere(
        (e) => e.toString().split('.').last == json['ruolo'],
      ),
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'username': username,
      'nome': nome,
      'cognome': cognome,
      'password': password,
      'email': email,
      'ruolo': ruolo.toString().split('.').last,
    };
  }
}