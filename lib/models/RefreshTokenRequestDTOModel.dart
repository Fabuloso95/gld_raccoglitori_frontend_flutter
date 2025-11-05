class RefreshtokenrequestdtoModel 
{
  final String refreshToken;

  RefreshtokenrequestdtoModel({required this.refreshToken});

  factory RefreshtokenrequestdtoModel.fromJson(Map<String, dynamic> json) 
  {
    return RefreshtokenrequestdtoModel(
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() 
  {
    return {'refreshToken': refreshToken};
  }
}
