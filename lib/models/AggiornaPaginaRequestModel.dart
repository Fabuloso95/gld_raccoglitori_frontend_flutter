class AggiornaPaginaRequestModel
{
  final int paginaCorrente;
  final bool partecipaChiamataZoom;

  AggiornaPaginaRequestModel({
    required this.paginaCorrente,
    required this.partecipaChiamataZoom
  });

  factory AggiornaPaginaRequestModel.fromJson(Map<String, dynamic> json)
  {
    return AggiornaPaginaRequestModel(
      paginaCorrente: (json['paginaCorrente'] as int).toInt(),
      partecipaChiamataZoom: json['partecipaChiamataZoom'] as bool,

    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'paginaCorrente': paginaCorrente,
      'partecipaChiamataZoom': partecipaChiamataZoom
    };
  }
}