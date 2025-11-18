import 'TipoEvento.dart';

class EventoResponse 
{
  final int? id;
  final String titolo;
  final String descrizione;
  final DateTime dataInizio;
  final DateTime dataFine;
  final TipoEvento tipoEvento;
  final String creatoDaUsername;
  final String coloreEvento;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EventoResponse({
    this.id,
    required this.titolo,
    required this.descrizione,
    required this.dataInizio,
    required this.dataFine,
    required this.tipoEvento,
    required this.creatoDaUsername,
    required this.coloreEvento,
    this.createdAt,
    this.updatedAt,
  });

  factory EventoResponse.fromJson(Map<String, dynamic> json) 
  {
    return EventoResponse(
      id: json['id'],
      titolo: json['titolo'],
      descrizione: json['descrizione'] ?? '',
      dataInizio: DateTime.parse(json['dataInizio']),
      dataFine: DateTime.parse(json['dataFine']),
      tipoEvento: _parseTipoEvento(json['tipoEvento']),
      creatoDaUsername: json['creatoDaUsername'],
      coloreEvento: json['coloreEvento'] ?? _getDefaultColor(json['tipoEvento']),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  static TipoEvento _parseTipoEvento(String tipo) 
  {
    switch (tipo) 
    {
      case 'VOTAZIONE':
        return TipoEvento.VOTAZIONE;
      case 'DISCUSSIONE':
        return TipoEvento.DISCUSSIONE;
      case 'INCONTRO':
        return TipoEvento.INCONTRO;
      case 'SCADENZA':
        return TipoEvento.SCADENZA;
      default:
        return TipoEvento.INCONTRO;
    }
  }

  static String _getDefaultColor(String tipo) 
  {
    switch (tipo) 
    {
      case 'VOTAZIONE':
        return '#FF6B6B';
      case 'DISCUSSIONE':
        return '#4ECDC4';
      case 'INCONTRO':
        return '#45B7D1';
      case 'SCADENZA':
        return '#FFA07A';
      default:
        return '#95A5A6';
    }
  }

  bool get isOngoing 
  {
    final now = DateTime.now();
    return now.isAfter(dataInizio) && now.isBefore(dataFine);
  }

  bool get isToday 
  {
    final now = DateTime.now();
    return now.year == dataInizio.year &&
        now.month == dataInizio.month &&
        now.day == dataInizio.day;
  }

  bool get isFuture 
  {
    return DateTime.now().isBefore(dataInizio);
  }

  String get formattedDateRange 
  {
    if (dataInizio.day == dataFine.day &&
        dataInizio.month == dataFine.month &&
        dataInizio.year == dataFine.year) 
    {
      return '${_formatDate(dataInizio)} ${_formatTime(dataInizio)} - ${_formatTime(dataFine)}';
    } 
    else 
    {
      return '${_formatDateTime(dataInizio)} - ${_formatDateTime(dataFine)}';
    }
  }

  String _formatDate(DateTime date) 
  {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) 
  {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date) 
  {
    return '${_formatDate(date)} ${_formatTime(date)}';
  }
}