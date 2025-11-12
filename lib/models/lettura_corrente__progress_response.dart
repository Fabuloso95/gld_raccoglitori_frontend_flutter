class LetturaCorrenteProgressResponse
{
  final int letturaCorrenteId;
  final String username;
  final int paginaCorrente;
  final bool partecipaChiamataZoom;

  LetturaCorrenteProgressResponse({
    required this.letturaCorrenteId,
    required this.username,
    required this.paginaCorrente,
    required this.partecipaChiamataZoom,
  });

  factory LetturaCorrenteProgressResponse.fromJson(Map<String, dynamic> json) 
  {
    return LetturaCorrenteProgressResponse(
      letturaCorrenteId: (json['letturaCorrenteId'] as int?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      paginaCorrente: (json['paginaCorrente'] as int?)?.toInt() ?? 0,
      partecipaChiamataZoom: json['partecipaChiamataZoom'] as bool? ?? false,
    );
  }
}