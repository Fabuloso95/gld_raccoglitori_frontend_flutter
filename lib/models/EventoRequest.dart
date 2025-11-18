import 'dart:ui';
import 'TipoEvento.dart';

class EventoRequest 
{
  final String titolo;
  final String descrizione;
  final DateTime dataInizio;
  final DateTime dataFine;
  final TipoEvento tipoEvento;

  EventoRequest({
    required this.titolo,
    required this.descrizione,
    required this.dataInizio,
    required this.dataFine,
    required this.tipoEvento,
  });

  Map<String, dynamic> toJson() 
  {
    return 
    {
      'titolo': titolo,
      'descrizione': descrizione,
      'dataInizio': dataInizio.toIso8601String(),
      'dataFine': dataFine.toIso8601String(),
      'tipoEvento': tipoEvento.toString().split('.').last,
    };
  }
}

extension TipoEventoExtension on TipoEvento 
{
  String get displayName 
  {
    switch (this) 
    {
      case TipoEvento.VOTAZIONE:
        return 'Votazione';
      case TipoEvento.DISCUSSIONE:
        return 'Discussione';
      case TipoEvento.INCONTRO:
        return 'Incontro';
      case TipoEvento.SCADENZA:
        return 'Scadenza';
    }
  }

  String get emoji 
  {
    switch (this) 
    {
      case TipoEvento.VOTAZIONE:
        return '🗳️';
      case TipoEvento.DISCUSSIONE:
        return '💬';
      case TipoEvento.INCONTRO:
        return '👥';
      case TipoEvento.SCADENZA:
        return '⏰';
    }
  }

  Color get color 
  {
    switch (this) 
    {
      case TipoEvento.VOTAZIONE:
        return const Color(0xFFFF6B6B);
      case TipoEvento.DISCUSSIONE:
        return const Color(0xFF4ECDC4);
      case TipoEvento.INCONTRO:
        return const Color(0xFF45B7D1);
      case TipoEvento.SCADENZA:
        return const Color(0xFFFFA07A);
    }
  }
}