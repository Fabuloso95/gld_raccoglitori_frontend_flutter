class NuovaPasswordRequestModel
{
  final String nuovaPassword;

  NuovaPasswordRequestModel({
    required this.nuovaPassword
  });

  factory NuovaPasswordRequestModel.fromJson(Map<String, dynamic> json) 
  {
    return NuovaPasswordRequestModel(
      nuovaPassword: json['nuovaPassword'],
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'nuovaPassword': nuovaPassword
    };
  }
}