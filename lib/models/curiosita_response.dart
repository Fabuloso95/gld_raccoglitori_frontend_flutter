import 'autore_commento_response.dart';

class CuriositaResponse 
{
  final int id;
  final int libroId;
  final String titolo;
  final String contenuto;
  final int paginaRiferimento;
  final AutoreCommentoResponse utenteCreatore;

  CuriositaResponse({
    required this.id,
    required this.libroId,
    required this.titolo,
    required this.contenuto,
    required this.paginaRiferimento,
    required this.utenteCreatore,
  });

  factory CuriositaResponse.fromJson(Map<String, dynamic> json) 
  {
    return CuriositaResponse(
      id: (json['id'] as int).toInt(),
      libroId: (json['libroId'] as int).toInt(),
      titolo: json['titolo'] as String,
      contenuto: json['contenuto'] as String,
      paginaRiferimento: (json['paginaRiferimento'] as int).toInt(),
      utenteCreatore: json['utenteId'] as AutoreCommentoResponse,
    );
  }
}