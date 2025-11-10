import 'package:flutter/foundation.dart';
import 'package:gld_raccoglitori/models/CuriositaRequestModel.dart';
import 'package:gld_raccoglitori/models/curiosita_response.dart';
import 'package:gld_raccoglitori/services/curiosita_api_service.dart';

class CuriositaViewModel extends ChangeNotifier 
{
  final CuriositaApiService _curiositaService;

  // Stato dell'applicazione
  List<CuriositaResponse> _curiosita = [];
  List<CuriositaResponse> _curiositaLibro = [];
  List<CuriositaResponse> _curiositaPagina = [];
  CuriositaResponse? _curiositaSelezionata;
  bool _isLoading = false;
  String? _error;
  int? _libroIdCorrente;
  int? _paginaCorrente;

  // Costruttore
  CuriositaViewModel(this._curiositaService);

  // Getter per lo stato
  List<CuriositaResponse> get curiosita => _curiosita;
  List<CuriositaResponse> get curiositaLibro => _curiositaLibro;
  List<CuriositaResponse> get curiositaPagina => _curiositaPagina;
  CuriositaResponse? get curiositaSelezionata => _curiositaSelezionata;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get libroIdCorrente => _libroIdCorrente;
  int? get paginaCorrente => _paginaCorrente;

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

  // Carica tutte le curiosità di un libro
  Future<void> caricaCuriositaPerLibro(int libroId) async 
  {
    _setLoading(true);
    _setError(null);
    _libroIdCorrente = libroId;
    
    try 
    {
      _curiositaLibro = await _curiositaService.getCuriositaByLibro(libroId: libroId);
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento delle curiosità del libro: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Carica curiosità per libro e pagina specifica
  Future<void> caricaCuriositaPerPagina({required int libroId, required int paginaRiferimento}) async 
  {
    _setLoading(true);
    _setError(null);
    _libroIdCorrente = libroId;
    _paginaCorrente = paginaRiferimento;
    
    try 
    {
      _curiositaPagina = await _curiositaService.getCuriositaByLibroAndPagina(
        libroId: libroId,
        paginaRiferimento: paginaRiferimento,
      );
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento delle curiosità della pagina: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Crea una nuova curiosità
  Future<bool> creaCuriosita(CuriositaRequestModel request) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final nuovaCuriosita = await _curiositaService.createCuriosita(request);
      
      // Aggiungi alla lista appropriata
      if (_libroIdCorrente == request.libroId) 
      {
        _curiositaLibro.add(nuovaCuriosita);
        
        // Se è per la stessa pagina, aggiungi anche a curiositaPagina
        if (_paginaCorrente == request.paginaRiferimento) 
        {
          _curiositaPagina.add(nuovaCuriosita);
        }
      }
      
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nella creazione della curiosità: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Aggiorna una curiosità
  Future<bool> aggiornaCuriosita({
    required int id,
    required CuriositaRequestModel request,
  }) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final curiositaAggiornata = await _curiositaService.updateCuriosita(
        id: id,
        request: request,
      );
      
      // Aggiorna nelle liste
      _aggiornaCuriositaNelleListe(curiositaAggiornata);
      
      // Aggiorna la curiosità selezionata se è quella
      if (_curiositaSelezionata?.id == id) 
      {
        _curiositaSelezionata = curiositaAggiornata;
      }
      
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nell\'aggiornamento della curiosità: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Elimina una curiosità
  Future<bool> eliminaCuriosita(int id) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      await _curiositaService.deleteCuriosita(id);
      
      // Rimuovi dalle liste
      _curiosita.removeWhere((c) => c.id == id);
      _curiositaLibro.removeWhere((c) => c.id == id);
      _curiositaPagina.removeWhere((c) => c.id == id);
      
      // Se la curiosità selezionata è quella eliminata, reset
      if (_curiositaSelezionata?.id == id) 
      {
        _curiositaSelezionata = null;
      }
      
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nell\'eliminazione della curiosità: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Ottieni una curiosità per ID
  Future<void> caricaCuriositaPerId(int id) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      _curiositaSelezionata = await _curiositaService.getCuriositaById(id);
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento della curiosità: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Metodi di utilità per la UI

  // Seleziona una curiosità
  void selezionaCuriosita(CuriositaResponse curiosita) 
  {
    _curiositaSelezionata = curiosita;
    notifyListeners();
  }

  // Deseleziona la curiosità corrente
  void deselezionaCuriosita() 
  {
    _curiositaSelezionata = null;
    notifyListeners();
  }

  // Crea curiosità rapida (metodo di utilità)
  Future<bool> creaCuriositaRapida({
    required int libroId,
    required String titolo,
    required String contenuto,
    required int paginaRiferimento,
  }) async 
  {
    final request = CuriositaRequestModel(
      libroId: libroId,
      titolo: titolo,
      contenuto: contenuto,
      paginaRiferimento: paginaRiferimento,
    );
    
    return await creaCuriosita(request);
  }

  // Pulisci gli errori
  void clearError() 
  {
    _setError(null);
  }

  // Reset dello stato
  void resetState() 
  {
    _curiosita = [];
    _curiositaLibro = [];
    _curiositaPagina = [];
    _curiositaSelezionata = null;
    _libroIdCorrente = null;
    _paginaCorrente = null;
    _setError(null);
    _setLoading(false);
    notifyListeners();
  }

  // Metodo privato per aggiornare una curiosità in tutte le liste
  void _aggiornaCuriositaNelleListe(CuriositaResponse curiositaAggiornata) 
  {
    final aggiornaInLista = (List<CuriositaResponse> lista) 
    {
      final index = lista.indexWhere((c) => c.id == curiositaAggiornata.id);
      if (index != -1) {
        lista[index] = curiositaAggiornata;
      }
    };

    aggiornaInLista(_curiosita);
    aggiornaInLista(_curiositaLibro);
    aggiornaInLista(_curiositaPagina);
  }

  Map<int, List<CuriositaResponse>> get curiositaPerLibro 
  {
    final map = <int, List<CuriositaResponse>>{};
    for (final curiosita in _curiositaLibro) {
      map.putIfAbsent(curiosita.libroId, () => []).add(curiosita);
    }
    return map;
  }
}