import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gld_raccoglitori/models/FrasePreferitaRequestModel.dart';
import 'package:gld_raccoglitori/models/frase_preferita_response.dart';
import 'package:gld_raccoglitori/services/frase_preferita_api_service.dart';

class FrasePreferitaViewModel extends ChangeNotifier 
{
  final FrasePreferitaApiService _frasePreferitaService;

  // Stato dell'applicazione
  List<FrasePreferitaResponse> _mieFrasi = [];
  List<FrasePreferitaResponse> _frasiLibro = [];
  FrasePreferitaResponse? _fraseSelezionata;
  bool _isLoading = false;
  String? _error;
  int? _libroIdCorrente;

  // Costruttore
  FrasePreferitaViewModel(this._frasePreferitaService);

  // Getter per lo stato
  List<FrasePreferitaResponse> get mieFrasi => _mieFrasi;
  List<FrasePreferitaResponse> get frasiLibro => _frasiLibro;
  FrasePreferitaResponse? get fraseSelezionata => _fraseSelezionata;
  bool get isLoading => _isLoading;
  String? get error => _error;
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
    if (!_isNotifying) {
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

  // Carica le frasi preferite dell'utente corrente
  Future<void> caricaMieFrasiPreferite() async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      _mieFrasi = await _frasePreferitaService.getMyFrasiPreferite();
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento delle tue frasi preferite: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Carica frasi preferite di un libro specifico
  Future<void> caricaFrasiPerLibro(int libroId) async 
  {
    _setLoading(true);
    _setError(null);
    _libroIdCorrente = libroId;
    
    try 
    {
      _frasiLibro = await _frasePreferitaService.getFrasiByLibro(libroId: libroId);
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento delle frasi del libro: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Salva una nuova frase preferita
  Future<bool> salvaFrasePreferita(FrasePreferitaRequestModel request) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final nuovaFrase = await _frasePreferitaService.saveFrase(request);
      
      // Aggiungi alla lista appropriata
      _mieFrasi.add(nuovaFrase);
      
      // Se è per lo stesso libro, aggiungi anche a frasiLibro
      if (_libroIdCorrente == request.libroId) 
      {
        _frasiLibro.add(nuovaFrase);
      }
      
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nel salvataggio della frase preferita: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Elimina una frase preferita
  Future<bool> eliminaFrasePreferita(int id) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      await _frasePreferitaService.deleteFrase(id);
      
      // Rimuovi dalle liste
      _mieFrasi.removeWhere((f) => f.id == id);
      _frasiLibro.removeWhere((f) => f.id == id);
      
      // Se la frase selezionata è quella eliminata, reset
      if (_fraseSelezionata?.id == id) 
      {
        _fraseSelezionata = null;
      }
      
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nell\'eliminazione della frase preferita: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Ottieni una frase per ID
  Future<void> caricaFrasePerId(int id) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      _fraseSelezionata = await _frasePreferitaService.getFrasePreferitaById(id);
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento della frase preferita: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Metodi di utilità per la UI

  // Salva frase rapida (metodo di utilità)
  Future<bool> salvaFraseRapida({
    required int utenteId,
    required int libroId,
    required String testoFrase,
    int? paginaRiferimento,
  }) async 
  {
    final request = FrasePreferitaRequestModel(
      utenteId: utenteId,
      libroId: libroId,
      testoFrase: testoFrase,
      paginaRiferimento: paginaRiferimento ?? 0,
    );
    
    return await salvaFrasePreferita(request);
  }

  // Verifica se una frase esiste già (per evitare duplicati)
  bool fraseEsisteGia(String testoFrase, int libroId) 
  {
    return _mieFrasi.any((frase) => 
      frase.testoFrase.toLowerCase() == testoFrase.toLowerCase() &&
      frase.libroId == libroId
    );
  }

  // Frasi per libro specifico (filtro locale)
  List<FrasePreferitaResponse> getFrasiPerLibro(int libroId) 
  {
    return _mieFrasi.where((frase) => frase.libroId == libroId).toList();
  }

  // Frasi per pagina specifica
  List<FrasePreferitaResponse> getFrasiPerPagina(int paginaRiferimento) 
  {
    return _mieFrasi.where((frase) => frase.paginaRiferimento == paginaRiferimento).toList();
  }

  // Aggiungi questo getter alla classe FrasePreferitaViewModel
  Map<int, List<FrasePreferitaResponse>> get frasiPerLibro 
  {
    final map = <int, List<FrasePreferitaResponse>>{};
    for (final frase in _frasiLibro) {
      map.putIfAbsent(frase.libroId, () => []).add(frase);
    }
    return map;
  }

  // Seleziona una frase
  void selezionaFrase(FrasePreferitaResponse frase) 
  {
    _fraseSelezionata = frase;
    notifyListeners();
  }

  // Deseleziona la frase corrente
  void deselezionaFrase() 
  {
    _fraseSelezionata = null;
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
    _mieFrasi = [];
    _frasiLibro = [];
    _fraseSelezionata = null;
    _libroIdCorrente = null;
    _setError(null);
    _setLoading(false);
    notifyListeners();
  }
}