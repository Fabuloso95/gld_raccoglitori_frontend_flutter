import 'package:flutter/foundation.dart';
import 'package:gld_raccoglitori/models/UtenteRequestModel.dart';
import 'package:gld_raccoglitori/models/UtenteUpdateRequestModel.dart';
import 'package:gld_raccoglitori/models/utente_response.dart';
import 'package:gld_raccoglitori/services/utente_api_service.dart';

class UtenteViewModel extends ChangeNotifier 
{
  final UtenteApiService _utenteService;

  // Stato dell'applicazione
  List<UtenteResponse> _utenti = [];
  UtenteResponse? _utenteSelezionato;
  bool _isLoading = false;
  String? _error;
  List<UtenteResponse> _utentiFiltrati = [];

  // Costruttore
  UtenteViewModel(this._utenteService);

  // Getter per lo stato
  List<UtenteResponse> get utenti => _utenti;
  UtenteResponse? get utenteSelezionato => _utenteSelezionato;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UtenteResponse> get utentiFiltrati => _utentiFiltrati;

  // Setter per lo stato
  set utentiFiltrati(List<UtenteResponse> value) 
  {
    _utentiFiltrati = value;
    notifyListeners();
  }

  // Metodi per gestire lo stato di caricamento ed errori
  void _setLoading(bool loading) 
  {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) 
  {
    _error = error;
    notifyListeners();
  }

  // Metodi per le operazioni CRUD

  // Carica tutti gli utenti
  Future<void> caricaUtenti() async 
  {
    _setLoading(true);
    _setError(null);
    
    try
    {
      _utenti = await _utenteService.getAllUtenti();
      _utentiFiltrati = _utenti; // Inizialmente mostra tutti gli utenti
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento degli utenti: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Crea un nuovo utente
  Future<bool> creaUtente(UtenteRequestModel request) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final nuovoUtente = await _utenteService.createUtente(request);
      _utenti.add(nuovoUtente);
      _utentiFiltrati = _utenti;
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nella creazione dell\'utente: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Ottiene un utente per ID
  Future<void> caricaUtentePerId(int id) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      _utenteSelezionato = await _utenteService.getUtenteById(id);
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento dell\'utente: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Aggiorna un utente
  Future<bool> aggiornaUtente({
    required int id,
    required UtenteUpdateRequestModel request,
  }) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final utenteAggiornato = await _utenteService.updateUtente(
        id: id,
        request: request,
      );
      
      // Aggiorna nella lista
      final index = _utenti.indexWhere((u) => u.id == id);
      if (index != -1) 
      {
        _utenti[index] = utenteAggiornato;
      }
      
      // Aggiorna l'utente selezionato se è quello
      if (_utenteSelezionato?.id == id) 
      {
        _utenteSelezionato = utenteAggiornato;
      }
      
      _utentiFiltrati = _utenti;
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nell\'aggiornamento dell\'utente: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Elimina un utente
  Future<bool> eliminaUtente(int id) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      await _utenteService.deleteUtente(id);
      
      // Rimuovi dalla lista
      _utenti.removeWhere((u) => u.id == id);
      _utentiFiltrati = _utenti;
      
      // Se l'utente selezionato è quello eliminato, reset
      if (_utenteSelezionato?.id == id) 
      {
        _utenteSelezionato = null;
      }
      
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nell\'eliminazione dell\'utente: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Attiva un utente
  Future<bool> attivaUtente(int id) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final utenteAttivato = await _utenteService.attivaUtente(id);
      
      // Aggiorna nella lista
      final index = _utenti.indexWhere((u) => u.id == id);
      if (index != -1) 
      {
        _utenti[index] = utenteAttivato;
      }
      
      _utentiFiltrati = _utenti;
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nell\'attivazione dell\'utente: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Disattiva un utente
  Future<bool> disattivaUtente(int id) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final utenteDisattivato = await _utenteService.disattivaUtente(id);
      
      // Aggiorna nella lista
      final index = _utenti.indexWhere((u) => u.id == id);
      if (index != -1) 
      {
        _utenti[index] = utenteDisattivato;
      }
      
      _utentiFiltrati = _utenti;
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nella disattivazione dell\'utente: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Cambia ruolo di un utente
  Future<bool> cambiaRuoloUtente({
    required int id,
    required String nuovoRuolo,
  }) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final utenteAggiornato = await _utenteService.cambiaRuolo(
        id: id,
        nuovoRuolo: nuovoRuolo,
      );
      
      // Aggiorna nella lista
      final index = _utenti.indexWhere((u) => u.id == id);
      if (index != -1) 
      {
        _utenti[index] = utenteAggiornato;
      }
      
      _utentiFiltrati = _utenti;
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nel cambio ruolo dell\'utente: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Cerca utenti
  Future<void> cercaUtenti(String term) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      if (term.isEmpty) 
      {
        _utentiFiltrati = _utenti;
      } 
      else 
      {
        _utentiFiltrati = await _utenteService.searchUtenti(term);
      }
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nella ricerca degli utenti: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Filtra utenti per ruolo
  Future<void> filtraUtentiPerRuolo(String ruolo) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      if (ruolo.isEmpty) 
      {
        _utentiFiltrati = _utenti;
      } 
      else 
      {
        _utentiFiltrati = await _utenteService.findByRuolo(ruolo);
      }
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel filtraggio degli utenti: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String token,
    required String nuovaPassword,
  }) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      await _utenteService.resetPassword(
        token: token,
        nuovaPassword: nuovaPassword,
      );
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nel reset della password: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Password dimenticata
  Future<bool> passwordDimenticata(String email) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      await _utenteService.forgotPassword(email);
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nella richiesta di reset password: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Metodi di utilità per la UI

  // Seleziona un utente
  void selezionaUtente(UtenteResponse utente) 
  {
    _utenteSelezionato = utente;
    notifyListeners();
  }

  // Deseleziona l'utente corrente
  void deselezionaUtente() 
  {
    _utenteSelezionato = null;
    notifyListeners();
  }

  // Pulisci gli errori
  void clearError() 
  {
    _setError(null);
  }

  // Reset dello stato
  void resetState() 
  {
    _utenti = [];
    _utenteSelezionato = null;
    _utentiFiltrati = [];
    _setError(null);
    _setLoading(false);
    notifyListeners();
  }
}