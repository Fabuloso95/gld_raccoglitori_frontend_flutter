import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/EventoRequest.dart';
import '../models/EventoResponse.dart';
import '../services/evento_service.dart';

class EventoViewModel with ChangeNotifier 
{
  final EventoService _eventoService;

  EventoViewModel({required EventoService eventoService}) : _eventoService = eventoService;

  // Stato
  List<EventoResponse> _eventi = [];
  bool _isLoading = false;
  String? _error;
  EventoResponse? _prossimaVotazione;
  EventoResponse? _prossimaDiscussione;

  // Getter
  List<EventoResponse> get eventi => _eventi;
  bool get isLoading => _isLoading;
  String? get error => _error;
  EventoResponse? get prossimaVotazione => _prossimaVotazione;
  EventoResponse? get prossimaDiscussione => _prossimaDiscussione;

  // Metodi
  Future<void> caricaEventiMensili(int year, int month) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      _eventi = await _eventoService.getEventiMensili(year, month);
      _notifyListenersSafe();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento eventi: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  Future<void> caricaEventiSettimanali(DateTime startDate) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      _eventi = await _eventoService.getEventiSettimanali(startDate);
      _notifyListenersSafe();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento eventi: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  Future<void> caricaProssimiEventi() async 
  {
    _setLoading(true);
    
    try 
    {
      _prossimaVotazione = await _eventoService.getProssimaVotazione();
      _prossimaDiscussione = await _eventoService.getProssimaDiscussione();
      _notifyListenersSafe();
    }
    catch (e) 
    {
      _setError('Errore nel caricamento prossimi eventi: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  Future<bool> creaEvento(EventoRequest evento) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final nuovoEvento = await _eventoService.creaEvento(evento);
      _eventi.add(nuovoEvento);
      _notifyListenersSafe();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nella creazione evento: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  Future<bool> aggiornaEvento(int id, EventoRequest evento) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final eventoAggiornato = await _eventoService.aggiornaEvento(id, evento);
      final index = _eventi.indexWhere((e) => e.id == id);
      if (index != -1) 
      {
        _eventi[index] = eventoAggiornato;
        _notifyListenersSafe();
      }
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nell\'aggiornamento evento: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  Future<bool> eliminaEvento(int id) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      await _eventoService.eliminaEvento(id);
      _eventi.removeWhere((e) => e.id == id);
      _notifyListenersSafe();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nell\'eliminazione evento: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  List<EventoResponse> getEventiDelGiorno(DateTime date) 
  {
    return _eventi.where((evento) 
    {
      return evento.dataInizio.year == date.year &&
             evento.dataInizio.month == date.month &&
             evento.dataInizio.day == date.day;
    }).toList();
  }

  void clearError() 
  {
    _setError(null);
  }

  void _setLoading(bool loading) 
  {
    _isLoading = loading;
    _notifyListenersSafe();
  }

  void _setError(String? error) 
  {
    _error = error;
    _notifyListenersSafe();
  }

  void _notifyListenersSafe() 
  {
    if (WidgetsBinding.instance.lifecycleState != null)
    {
      WidgetsBinding.instance.addPostFrameCallback((_) 
      {
        notifyListeners();
      });
    } 
    else 
    {
      notifyListeners();
    }
  }
}