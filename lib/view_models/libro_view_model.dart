import 'package:flutter/foundation.dart';
import 'package:gld_raccoglitori/models/LibroRequestModel.dart';
import 'package:gld_raccoglitori/models/libro_response.dart';
import 'package:gld_raccoglitori/services/libro_api_service.dart';

class LibroViewModel extends ChangeNotifier 
{
  final LibroApiService _libroService;

  // Stato dell'applicazione
  List<LibroResponse> _libri = [];
  List<LibroResponse> _libriFiltrati = [];
  LibroResponse? _libroSelezionato;
  bool _isLoading = false;
  String? _error;
  String? _termineRicerca;

  // Costruttore
  LibroViewModel(this._libroService);

  // Getter per lo stato
  List<LibroResponse> get libri => _libri;
  List<LibroResponse> get libriFiltrati => _libriFiltrati;
  LibroResponse? get libroSelezionato => _libroSelezionato;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get termineRicerca => _termineRicerca;

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

  // Carica tutti i libri
  Future<void> caricaLibri() async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      _libri = await _libroService.getAllLibriOrSearch();
      _libriFiltrati = _libri;
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento dei libri: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Cerca libri
  Future<void> cercaLibri(String termine) async 
  {
    _setLoading(true);
    _setError(null);
    _termineRicerca = termine;
    
    try 
    {
      if (termine.isEmpty) 
      {
        _libriFiltrati = _libri;
      } 
      else 
      {
        _libriFiltrati = await _libroService.getAllLibriOrSearch(searchTerm: termine);
      }
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nella ricerca dei libri: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Crea un nuovo libro
  Future<bool> creaLibro(LibroRequestModel request) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final nuovoLibro = await _libroService.creaLibro(request);
      _libri.add(nuovoLibro);
      _libriFiltrati = _libri;
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nella creazione del libro: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Aggiorna un libro
  Future<bool> aggiornaLibro({required int id, required LibroRequestModel request}) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final libroAggiornato = await _libroService.aggiornaLibro(
        id: id,
        request: request,
      );
      
      // Aggiorna nella lista
      final index = _libri.indexWhere((l) => l.id == id);
      if (index != -1) 
      {
        _libri[index] = libroAggiornato;
      }
      
      // Aggiorna nella lista filtrata
      final indexFiltrato = _libriFiltrati.indexWhere((l) => l.id == id);
      if (indexFiltrato != -1) 
      {
        _libriFiltrati[indexFiltrato] = libroAggiornato;
      }
      
      // Aggiorna il libro selezionato se è quello
      if (_libroSelezionato?.id == id) 
      {
        _libroSelezionato = libroAggiornato;
      }
      
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nell\'aggiornamento del libro: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Elimina un libro
  Future<bool> eliminaLibro(int id) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      await _libroService.eliminaLibro(id);
      
      // Rimuovi dalle liste
      _libri.removeWhere((l) => l.id == id);
      _libriFiltrati.removeWhere((l) => l.id == id);
      
      // Se il libro selezionato è quello eliminato, reset
      if (_libroSelezionato?.id == id) 
      {
        _libroSelezionato = null;
      }
      
      notifyListeners();
      return true;
    } 
    catch (e)
    {
      _setError('Errore nell\'eliminazione del libro: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Ottieni un libro per ID
  Future<void> caricaLibroPerId(int id) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      _libroSelezionato = await _libroService.getLibroById(id);
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento del libro: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Metodi di utilità per la UI

  // Crea libro rapido (metodo di utilità)
  Future<bool> creaLibroRapido({
    required String titolo,
    required String autore,
    required String copertinaUrl,
    required String sinossi,
    required int annoPubblicazione,
    required int numeroPagine,
  }) async 
  {
    final request = LibroRequestModel(
      titolo: titolo,
      autore: autore,
      copertinaUrl: copertinaUrl,
      sinossi: sinossi,
      annoPubblicazione: annoPubblicazione,
      numeroPagine: numeroPagine,
    );
    
    return await creaLibro(request);
  }

  // Filtra libri localmente (senza chiamata API)
  void filtraLibriLocalmente(String termine) 
  {
    _termineRicerca = termine;
    
    if (termine.isEmpty) 
    {
      _libriFiltrati = _libri;
    } 
    else 
    {
      final termineLower = termine.toLowerCase();
      _libriFiltrati = _libri.where((libro) =>
        libro.titolo.toLowerCase().contains(termineLower) ||
        libro.autore.toLowerCase().contains(termineLower) ||
        libro.sinossi.toLowerCase().contains(termineLower)
      ).toList();
    }
    
    notifyListeners();
  }

  // Libri letti
  List<LibroResponse> get libriLetti 
  {
    return _libri.where((libro) => libro.letto).toList();
  }

  // Libri non letti
  List<LibroResponse> get libriNonLetti 
  {
    return _libri.where((libro) => !libro.letto).toList();
  }

  // Seleziona un libro
  void selezionaLibro(LibroResponse libro) 
  {
    _libroSelezionato = libro;
    notifyListeners();
  }

  // Deseleziona il libro corrente
  void deselezionaLibro() 
  {
    _libroSelezionato = null;
    notifyListeners();
  }

  // Verifica se un libro esiste già (per evitare duplicati)
  bool libroEsisteGia(String titolo, String autore) 
  {
    return _libri.any((libro) =>
      libro.titolo.toLowerCase() == titolo.toLowerCase() &&
      libro.autore.toLowerCase() == autore.toLowerCase()
    );
  }

  // Pulisci gli errori
  void clearError() 
  {
    _setError(null);
  }

  // Reset dello stato
  void resetState() 
  {
    _libri = [];
    _libriFiltrati = [];
    _libroSelezionato = null;
    _termineRicerca = null;
    _setError(null);
    _setLoading(false);
    notifyListeners();
  }
}