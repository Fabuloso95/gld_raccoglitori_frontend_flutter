class LoginRequestModel 
{
  final String usernameOrEmail; 
  final String password;

  LoginRequestModel({
    required this.usernameOrEmail,
    required this.password,
  });

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) 
  {
    return LoginRequestModel(
      usernameOrEmail: json['usernameOrEmail'],
      password: json['password']
    );
  }

  Map<String, dynamic> toJson() 
  {
    return 
    {
      'usernameOrEmail': usernameOrEmail, 
      'password': password,
    };
  }
}