import 'package:flutter/foundation.dart';
import 'package:gld_raccoglitori/models/voto_utente_response.dart';
import 'package:gld_raccoglitori/services/voto_utente_api_service.dart';
import 'package:gld_raccoglitori/services/auth_service.dart';

class VotoUtenteViewModel extends ChangeNotifier 
{
  final VotoUtenteApiService _votoUtenteService;
  final AuthService _authService;

  // Stato dell'applicazione
  List<VotoUtenteResponse> _votiUtenteCorrente = [];
  VotoUtenteResponse? _votoSelezionato;
  bool _isLoading = false;
  String? _error;
  String _meseCorrente = '';

  // Costruttore
  VotoUtenteViewModel(this._votoUtenteService, this._authService) 
  {
    _caricaMeseCorrente();
  }

  // Getter per lo stato
  List<VotoUtenteResponse> get votiUtenteCorrente => _votiUtenteCorrente;
  VotoUtenteResponse? get votoSelezionato => _votoSelezionato;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get meseCorrente => _meseCorrente;
  int? get utenteIdCorrente => _authService.currentUserId;

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

  // Calcola il mese corrente nel formato "YYYY-MM"
  void _caricaMeseCorrente() 
  {
    final now = DateTime.now();
    _meseCorrente = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  // Verifica se l'utente ha già votato per una proposta specifica
  bool haVotatoPerProposta(int propostaId) 
  {
    return _votiUtenteCorrente.any((voto) => voto.propostaVotoId == propostaId);
  }

  // Ottieni tutti i voti dell'utente per il mese corrente
  Future<void> caricaVotiUtenteCorrente() async 
  {
    if (_authService.currentUserId == null) 
    {
      _setError('Utente non autenticato');
      return;
    }

    _setLoading(true);
    _setError(null);
    
    try 
    {
      _votiUtenteCorrente = await _votoUtenteService.checkExistingVote(meseVotazione: _meseCorrente);
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento dei voti: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Carica un voto specifico per ID
  Future<void> caricaVotoPerId(int id) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      _votoSelezionato = await _votoUtenteService.findById(id);
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento del voto: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Verifica se l'utente può votare ancora (massimo 3 voti per mese)
  bool get puoVotareAncora 
  {
    return _votiUtenteCorrente.length < 3;
  }

  // Numero di voti rimanenti per l'utente
  int get votiRimanenti 
  {
    return 3 - _votiUtenteCorrente.length;
  }

  // Ottieni i proposalId per cui l'utente ha già votato
  List<int> get propostaIdVotati 
  {
    return _votiUtenteCorrente.map((voto) => voto.propostaVotoId).toList();
  }

  // Aggiungi un voto localmente (usato dopo una votazione di successo)
  void aggiungiVotoLocalmente(VotoUtenteResponse voto) 
  {
    _votiUtenteCorrente.add(voto);
    notifyListeners();
  }

  // Rimuovi un voto localmente
  void rimuoviVotoLocalmente(int propostaId) 
  {
    _votiUtenteCorrente.removeWhere((voto) => voto.propostaVotoId == propostaId);
    notifyListeners();
  }

  // Verifica se l'utente ha voti per un mese specifico
  bool haVotiPerMese(String mese) 
  {
    return _votiUtenteCorrente.any((voto) => voto.meseVotazione == mese);
  }

  // Seleziona un voto
  void selezionaVoto(VotoUtenteResponse voto) 
  {
    _votoSelezionato = voto;
    notifyListeners();
  }

  // Deseleziona il voto corrente
  void deselezionaVoto() 
  {
    _votoSelezionato = null;
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
    _votiUtenteCorrente = [];
    _votoSelezionato = null;
    _setError(null);
    _setLoading(false);
    notifyListeners();
  }

  // Aggiorna il ViewModel quando un voto viene aggiunto tramite PropostaVotoViewModel
  void onVotoAggiunto(int propostaVotoId) 
  {
    // Crea un voto temporaneo per lo stato locale
    final nuovoVoto = VotoUtenteResponse(
      id: -1, // ID temporaneo, sarà aggiornato dal backend
      utenteId: _authService.currentUserId!,
      propostaVotoId: propostaVotoId,
      meseVotazione: _meseCorrente,
    );
    
    _votiUtenteCorrente.add(nuovoVoto);
    notifyListeners();
  }

  // Aggiorna il ViewModel quando un voto viene rimosso tramite PropostaVotoViewModel
  void onVotoRimosso(int propostaVotoId) 
  {
    _votiUtenteCorrente.removeWhere((voto) => voto.propostaVotoId == propostaVotoId);
    notifyListeners();
  }
}