class LibroResponse 
{
  final int id;
  final String titolo;
  final String autore;
  final String copertinaUrl;
  final String sinossi;
  final int annoPubblicazione;
  final int numeroPagine;
  final bool letto;

  LibroResponse({
    required this.id,
    required this.titolo,
    required this.autore,
    required this.copertinaUrl,
    required this.sinossi,
    required this.annoPubblicazione,
    required this.numeroPagine,
    required this.letto,
  });

  factory LibroResponse.fromJson(Map<String, dynamic> json) 
  {
    return LibroResponse(
      id: (json['id'] as int).toInt(),
      titolo: json['titolo'] as String,
      autore: json['autore'] as String,
      copertinaUrl: json['copertinaUrl'] as String,
      sinossi: json['sinossi'] as String,
      annoPubblicazione: (json['annoPubblicazione'] as int).toInt(),
      numeroPagine: (json['numeroPagine'] as int).toInt(),
      letto: (json['letto'] as bool) 
    );
  }
}