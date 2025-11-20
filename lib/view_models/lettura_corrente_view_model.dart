import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gld_raccoglitori/models/LetturaCorrenteRequestModel.dart';
import 'package:gld_raccoglitori/models/LetturaCorrenteUpdateRequestModel.dart';
import 'package:gld_raccoglitori/models/lettura_corrente_response.dart';
import 'package:gld_raccoglitori/services/lettura_corrente_api_service.dart';

class LetturaCorrenteViewModel extends ChangeNotifier 
{
  final LetturaCorrenteApiService _letturaService;

  // Stato dell'applicazione
  List<LetturaCorrenteResponse> _mieLetture = [];
  LetturaCorrenteResponse? _letturaCorrente;
  bool _isLoading = false;
  String? _error;
  int _paginaCorrente = 1;
  int? _libroIdCorrente;

  // Costruttore
  LetturaCorrenteViewModel(this._letturaService);

  // Getter per lo stato
  List<LetturaCorrenteResponse> get mieLetture => _mieLetture;
  LetturaCorrenteResponse? get letturaCorrente => _letturaCorrente;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get paginaCorrente => _paginaCorrente;
  int? get libroIdCorrente => _libroIdCorrente;

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

  void _safeNotifyListeners() 
  {
    if (!_isNotifying) 
    {
      _isNotifying = true;
      WidgetsBinding.instance.addPostFrameCallback((_)
      {
        _isNotifying = false;
        notifyListeners();
      });
    }
  }

  bool _isNotifying = false;

  // Metodi per le operazioni CRUD

  // Carica tutte le letture dell'utente corrente
  Future<void> caricaMieLetture() async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      _mieLetture = await _letturaService.getMyReadings();
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento delle tue letture: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Inizia una nuova lettura
  Future<bool> iniziaLettura({
    required int libroId,
    required int paginaIniziale,
  }) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final request = LetturaCorrenteRequestModel(
        libroId: libroId,
        paginaIniziale: paginaIniziale,
      );

      final nuovaLettura = await _letturaService.startReading(request);
      _letturaCorrente = nuovaLettura;
      _paginaCorrente = paginaIniziale;
      _libroIdCorrente = libroId;
      
      // Aggiungi alla lista
      _mieLetture.add(nuovaLettura);
      
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nell\'inizio della lettura: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Aggiorna il progresso della lettura
  Future<bool> aggiornaProgresso({
    required int letturaId,
    required int nuovaPagina,
    required bool partecipaChiamataZoom,
  }) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final request = LetturaCorrenteUpdateRequestModel(
        paginaCorrente: nuovaPagina,
        partecipaChiamataZoom: partecipaChiamataZoom,
      );

      final letturaAggiornata = await _letturaService.updateProgress(
        id: letturaId,
        request: request,
      );
      
      // Aggiorna lo stato
      _letturaCorrente = letturaAggiornata;
      _paginaCorrente = nuovaPagina;
      
      // Aggiorna nella lista
      final index = _mieLetture.indexWhere((l) => l.id == letturaId);
      if (index != -1) 
      {
        _mieLetture[index] = letturaAggiornata;
      }
      
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nell\'aggiornamento del progresso: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Completa una lettura
  Future<bool> completaLettura(int letturaId) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final letturaCompletata = await _letturaService.completeReading(id: letturaId);
      
      // Aggiorna lo stato
      _letturaCorrente = letturaCompletata;
      
      // Aggiorna nella lista
      final index = _mieLetture.indexWhere((l) => l.id == letturaId);
      if (index != -1) 
      {
        _mieLetture[index] = letturaCompletata;
      }
      
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nel completamento della lettura: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Elimina una lettura
  Future<bool> eliminaLettura(int letturaId) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      await _letturaService.deleteReading(letturaId);
      
      // Rimuovi dalla lista
      _mieLetture.removeWhere((l) => l.id == letturaId);
      
      // Se la lettura corrente è quella eliminata, reset
      if (_letturaCorrente?.id == letturaId) 
      {
        _letturaCorrente = null;
        _paginaCorrente = 1;
        _libroIdCorrente = null;
      }
      
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nell\'eliminazione della lettura: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Metodi di utilità per la UI

  // Imposta la lettura corrente
  void impostaLetturaCorrente(LetturaCorrenteResponse lettura) 
  {
    _letturaCorrente = lettura;
    _paginaCorrente = lettura.paginaCorrente;
    _libroIdCorrente = lettura.libroId;
    notifyListeners();
  }

  LetturaCorrenteResponse? getLetturaPerLibro(int libroId) 
  {
    try 
    {
      return _mieLetture.firstWhere((lettura) => 
        lettura.libroId == libroId && lettura.dataCompletamento == null
      );
    } 
    catch (e) 
    {
      return null;
    }
  }

  Future<bool> vaiPaginaSuccessiva() async 
  {
    if (_letturaCorrente == null) return false;
    
    final nuovaPagina = _paginaCorrente + 1;
    return await aggiornaProgresso(
      letturaId: _letturaCorrente!.id,
      nuovaPagina: nuovaPagina,
      partecipaChiamataZoom: _letturaCorrente!.partecipaChiamataZoom,
    );
  }

  // Vai alla pagina precedente
  Future<bool> vaiPaginaPrecedente() async 
  {
    if (_letturaCorrente == null || _paginaCorrente <= 1) return false;
    
    final nuovaPagina = _paginaCorrente - 1;
    return await aggiornaProgresso(
      letturaId: _letturaCorrente!.id,
      nuovaPagina: nuovaPagina,
      partecipaChiamataZoom: _letturaCorrente!.partecipaChiamataZoom,
    );
  }

  // Vai a una pagina specifica
  Future<bool> vaiAPagina(int pagina) async 
  {
    if (_letturaCorrente == null || pagina < 1) return false;
    
    return await aggiornaProgresso(
      letturaId: _letturaCorrente!.id,
      nuovaPagina: pagina,
      partecipaChiamataZoom: _letturaCorrente!.partecipaChiamataZoom,
    );
  }

  // Calcola percentuale di completamento (supponendo 350 pagine totali)
  double get percentualeCompletamento 
  {
    if (_letturaCorrente == null) return 0.0;
    return (_paginaCorrente / 350 * 100); // TODO: Sostituire con numeroPagine reale
  }

  // Verifica se la lettura è attiva
  bool get letturaAttiva => _letturaCorrente != null && _letturaCorrente!.dataCompletamento == null;

  // Pulisci gli errori
  void clearError() 
  {
    _setError(null);
  }

  // Reset dello stato
  void resetState() 
  {
    _mieLetture = [];
    _letturaCorrente = null;
    _paginaCorrente = 1;
    _libroIdCorrente = null;
    _setError(null);
    _setLoading(false);
    notifyListeners();
  }
}