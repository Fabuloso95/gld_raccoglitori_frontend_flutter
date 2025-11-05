class LibroRequestModel
{
  final String titolo;
  final String autore;
  final String copertinaUrl;
  final String sinossi;
  final int annoPubblicazione;
  final int numeroPagine;

  LibroRequestModel({
    required this.titolo,
    required this.autore,
    required this.copertinaUrl,
    required this.sinossi,
    required this.annoPubblicazione,
    required this.numeroPagine
  });

  factory LibroRequestModel.fromJson(Map<String, dynamic> json) 
  {
    return LibroRequestModel(
      titolo: json['titolo'],
      autore: json['autore'],
      copertinaUrl: json['copertinaUrl'],
      sinossi: json['sinossi'],
      annoPubblicazione: (json['annoPubblicazione'] as num).toInt(),
      numeroPagine: (json['numeroPagine'] as num).toInt()
    );
  }

  Map<String, dynamic> toJson()
  {
    return
    {
      'titolo': titolo,
      'autore': autore,
      'copertinaUrl': copertinaUrl,
      'sinossi': sinossi,
      'annoPubblicazione': annoPubblicazione,
      'numeroPagine': numeroPagine,
    };
  }
}