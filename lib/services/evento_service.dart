import '../models/EventoRequest.dart';
import '../models/EventoResponse.dart';
import '../repository/evento_repository.dart';

class EventoService 
{
  final EventoRepository _repository;

  EventoService({required EventoRepository repository}) : _repository = repository;

  Future<List<EventoResponse>> getEventiMensili(int year, int month) async 
  {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    return await _repository.getEventiNelPeriodo(firstDay, lastDay);
  }

  Future<List<EventoResponse>> getEventiSettimanali(DateTime startDate) async 
  {
    final endDate = startDate.add(const Duration(days: 7));
    return await _repository.getEventiNelPeriodo(startDate, endDate);
  }

  Future<List<EventoResponse>> getEventiGiornalieri(DateTime date) async 
  {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return await _repository.getEventiNelPeriodo(startOfDay, endOfDay);
  }

  Future<EventoResponse> creaEvento(EventoRequest evento) async 
  {
    return await _repository.creaEvento(evento);
  }

  Future<EventoResponse> aggiornaEvento(int id, EventoRequest evento) async 
  {
    return await _repository.aggiornaEvento(id, evento);
  }

  Future<void> eliminaEvento(int id) async 
  {
    await _repository.eliminaEvento(id);
  }

  Future<EventoResponse?> getProssimaVotazione() async 
  {
    return await _repository.getProssimaVotazione();
  }

  Future<EventoResponse?> getProssimaDiscussione() async 
  {
    return await _repository.getProssimaDiscussione();
  }

  Future<EventoResponse> getEventoById(int id) async 
  {
    return await _repository.getEventoById(id);
  }
}