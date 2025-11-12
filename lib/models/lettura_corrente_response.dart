import 'commento_pagina_response.dart';

class LetturaCorrenteResponse
{
  final int id;
  final int utenteId;
  final int libroId;
  final int paginaCorrente;
  final DateTime dataInizio; 
  final DateTime? dataCompletamento; 
  final bool partecipaChiamataZoom;
  final List<CommentoPaginaResponse> commentiPagina;

  LetturaCorrenteResponse({
    required this.id,
    required this.utenteId,
    required this.libroId,
    required this.paginaCorrente,
    required this.dataInizio,
    required this.dataCompletamento,
    required this.partecipaChiamataZoom,
    required this.commentiPagina,
  });

  factory LetturaCorrenteResponse.fromJson(Map<String, dynamic> json) 
  {
    return LetturaCorrenteResponse(
      id: (json['id'] as int?)?.toInt() ?? 0,
      utenteId: (json['utenteId'] as int?)?.toInt() ?? 0,
      libroId: (json['libroId'] as int?)?.toInt() ?? 0,
      paginaCorrente: (json['paginaCorrente'] as int?)?.toInt() ?? 0,
      dataInizio: DateTime.parse(json['dataInizio'] as String? ?? ''),
      dataCompletamento: json['dataCompletamento'] != null 
          ? DateTime.parse(json['dataCompletamento'] as String)
          : null, // <-- QUESTO era il problema!
      partecipaChiamataZoom: json['partecipaChiamataZoom'] as bool? ?? false,
      commentiPagina: (json['commentiPagina'] as List<dynamic>?)
          ?.map((commento) => CommentoPaginaResponse.fromJson(commento))
          .toList() ?? [],
    );
  }
}