class UpdateContenutoRequestModel
{
  final String nuovoContenuto;

  UpdateContenutoRequestModel({
    required this.nuovoContenuto
  });

  factory UpdateContenutoRequestModel.fromJson(Map<String, dynamic> json) 
  {
    return UpdateContenutoRequestModel(
      nuovoContenuto: json['nuovoContenuto'],
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'nuovoContenuto': nuovoContenuto
    };
  }
}