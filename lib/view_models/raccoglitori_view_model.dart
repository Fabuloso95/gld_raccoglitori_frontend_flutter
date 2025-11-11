import 'package:flutter/foundation.dart';
import 'package:gld_raccoglitori/services/raccoglitori_api_service.dart';

class RaccoglitoriViewModel extends ChangeNotifier 
{
  final RaccoglitoriApiService _raccoglitoriService;

  // Stato dell'applicazione
  List<Raccoglitore> _raccoglitori = [];
  List<Raccoglitore> _raccoglitoriFiltrati = [];
  Raccoglitore? _raccoglitoreSelezionato;
  bool _isLoading = false;
  String? _error;
  String? _termineRicerca;

  // Costruttore
  RaccoglitoriViewModel(this._raccoglitoriService);

  // Getter per lo stato
  List<Raccoglitore> get raccoglitori => _raccoglitori;
  List<Raccoglitore> get raccoglitoriFiltrati => _raccoglitoriFiltrati;
  Raccoglitore? get raccoglitoreSelezionato => _raccoglitoreSelezionato;
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

  // Carica tutti i raccoglitori
  Future<void> caricaRaccoglitori() async
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      _raccoglitori = await _raccoglitoriService.getElencoRaccoglitori();
      _raccoglitoriFiltrati = _raccoglitori;
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento dei raccoglitori: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Crea un nuovo raccoglitore
  Future<bool> creaRaccoglitore(String nome, String cognome) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final nuovoRaccoglitore = await _raccoglitoriService.createRaccoglitore(nome, cognome);
      _raccoglitori.add(nuovoRaccoglitore);
      _raccoglitoriFiltrati = _raccoglitori;
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nella creazione del raccoglitore: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Cerca raccoglitori
  void cercaRaccoglitori(String termine) 
  {
    _termineRicerca = termine;
    
    if (termine.isEmpty) 
    {
      _raccoglitoriFiltrati = _raccoglitori;
    } 
    else 
    {
      final termineLower = termine.toLowerCase();
      _raccoglitoriFiltrati = _raccoglitori.where((raccoglitore) =>
        raccoglitore.nome.toLowerCase().contains(termineLower) ||
        raccoglitore.cognome.toLowerCase().contains(termineLower)
      ).toList();
    }
    
    notifyListeners();
  }

  // Seleziona un raccoglitore
  void selezionaRaccoglitore(Raccoglitore raccoglitore) 
  {
    _raccoglitoreSelezionato = raccoglitore;
    notifyListeners();
  }

  // Deseleziona il raccoglitore corrente
  void deselezionaRaccoglitore() 
  {
    _raccoglitoreSelezionato = null;
    notifyListeners();
  }

  // Verifica se un raccoglitore esiste già
  bool raccoglitoreEsisteGia(String nome, String cognome) 
  {
    return _raccoglitori.any((raccoglitore) =>
      raccoglitore.nome.toLowerCase() == nome.toLowerCase() &&
      raccoglitore.cognome.toLowerCase() == cognome.toLowerCase()
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
    _raccoglitori = [];
    _raccoglitoriFiltrati = [];
    _raccoglitoreSelezionato = null;
    _termineRicerca = null;
    _setError(null);
    _setLoading(false);
    notifyListeners();
  }
}