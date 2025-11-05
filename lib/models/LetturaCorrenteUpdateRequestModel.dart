class LetturaCorrenteUpdateRequestModel
{
    final int paginaCorrente;
    final bool partecipaChiamataZoom;

    LetturaCorrenteUpdateRequestModel({
        required this.paginaCorrente,
        required this.partecipaChiamataZoom
    });

    Map<String, dynamic> toJson()
    {
        return
        {
            'paginaCorrente': paginaCorrente,
            'partecipaChiamataZoom': partecipaChiamataZoom
        };
    }
}