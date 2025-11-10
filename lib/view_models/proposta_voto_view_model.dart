import 'package:flutter/foundation.dart';
import 'package:gld_raccoglitori/models/PropostaVotoRequestModel.dart';
import 'package:gld_raccoglitori/models/VotoUtenteRequestModel.dart';
import 'package:gld_raccoglitori/models/proposta_voto_response.dart';
import 'package:gld_raccoglitori/models/voto_utente_response.dart';
import 'package:gld_raccoglitori/services/proposta_voto_api_service.dart';
import 'package:gld_raccoglitori/services/auth_service.dart';

class PropostaVotoViewModel extends ChangeNotifier 
{
  final PropostaVotoApiService _propostaVotoService;
  final AuthService _authService;

  // Stato dell'applicazione
  List<PropostaVotoResponse> _proposteCorrenti = [];
  List<PropostaVotoResponse> _proposteStoriche = [];
  List<VotoUtenteResponse> _votiUtenteCorrente = [];
  PropostaVotoResponse? _propostaSelezionata;
  PropostaVotoResponse? _vincitoreMeseCorrente;
  bool _isLoading = false;
  String? _error;
  String _meseCorrente = '';

  // Costruttore
  PropostaVotoViewModel(this._propostaVotoService, this._authService) 
  {
    _caricaMeseCorrente();
  }

  // Getter per lo stato
  List<PropostaVotoResponse> get proposteCorrenti => _proposteCorrenti;
  List<PropostaVotoResponse> get proposteStoriche => _proposteStoriche;
  PropostaVotoResponse? get propostaSelezionata => _propostaSelezionata;
  PropostaVotoResponse? get vincitoreMeseCorrente => _vincitoreMeseCorrente;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get meseCorrente => _meseCorrente;
  int? get utenteIdCorrente => _authService.currentUserId;
  
  // Verifica se l'utente ha già votato per una proposta
  bool haVotatoPerProposta(int propostaId) {
    return _votiUtenteCorrente.any((voto) => voto.propostaVotoId == propostaId);
  }
  
  // Numero totale di voti dell'utente questo mese
  int get votiUtenteCorrente => _votiUtenteCorrente.length;
  
  // Massimo voti consentiti
  int get maxVotiConsentiti => 3;

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

  // Carica le proposte del mese corrente
  Future<void> caricaProposteMeseCorrente() async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      _proposteCorrenti = await _propostaVotoService.getProposteByMese(meseVotazione: _meseCorrente);
      await _caricaVotiUtenteCorrente();
      await _caricaVincitoreMeseCorrente();
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento delle proposte: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Carica i voti dell'utente corrente per questo mese
  Future<void> _caricaVotiUtenteCorrente() async 
  {
    // NOTA: Qui dovrei implementare una chiamata API per ottenere i voti dell'utente
    // Per ora, inizializzo come lista vuota - il backend gestirà la logica
    _votiUtenteCorrente = [];
    
    // Se hai un endpoint per ottenere i voti dell'utente, implementalo qui:
    // _votiUtenteCorrente = await _propostaVotoService.getVotiUtente(meseVotazione: _meseCorrente);
  }

  // Carica il vincitore del mese corrente
  Future<void> _caricaVincitoreMeseCorrente() async 
  {
    try 
    {
      _vincitoreMeseCorrente = await _propostaVotoService.getWinnerProposta(_meseCorrente);
    } 
    catch (e) 
    {
      // Se non c'è un vincitore, è normale (potrebbe essere ancora in corso la votazione)
      _vincitoreMeseCorrente = null;
    }
  }

  // Proponi un nuovo libro per la votazione
  Future<bool> proponiLibro(int libroId) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final request = PropostaVotoRequestModel(
        libroId: libroId,
        meseVotazione: _meseCorrente,
      );
      
      final nuovaProposta = await _propostaVotoService.createProposta(request);
      _proposteCorrenti.add(nuovaProposta);
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nella proposta del libro: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Vota per una proposta
  Future<bool> votaPerProposta(int propostaId) async 
  {
    if (_authService.currentUserId == null) 
    {
      _setError('Utente non autenticato');
      return false;
    }

    // Il backend gestirà i controlli sui voti massimi e duplicati
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final request = VotoUtenteRequestModel(
        propostaVotoId: propostaId,
        meseVotazione: _meseCorrente,
      );
      
      final voto = await _propostaVotoService.voteForProposta(request);
      
      // Aggiorna lo stato locale
      _votiUtenteCorrente.add(voto);
      
      // Aggiorna il conteggio voti nella proposta
      final propostaIndex = _proposteCorrenti.indexWhere((p) => p.id == propostaId);
      if (propostaIndex != -1) 
      {
        final propostaAggiornata = PropostaVotoResponse(
          id: _proposteCorrenti[propostaIndex].id,
          libroProposto: _proposteCorrenti[propostaIndex].libroProposto,
          meseVotazione: _proposteCorrenti[propostaIndex].meseVotazione,
          dataCreazione: _proposteCorrenti[propostaIndex].dataCreazione,
          numVoti: _proposteCorrenti[propostaIndex].numVoti + 1,
        );
        _proposteCorrenti[propostaIndex] = propostaAggiornata;
      }
      
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nel voto: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Rimuovi voto da una proposta
  Future<bool> rimuoviVoto(int propostaId) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      // NOTA: Qui dovresti implementare una chiamata API per rimuovere il voto
      // Per ora, gestiamo solo lo stato locale
      
      // Rimuovi dalla lista voti utente
      _votiUtenteCorrente.removeWhere((voto) => voto.propostaVotoId == propostaId);
      
      // Aggiorna il conteggio voti nella proposta
      final propostaIndex = _proposteCorrenti.indexWhere((p) => p.id == propostaId);
      if (propostaIndex != -1 && _proposteCorrenti[propostaIndex].numVoti > 0) 
      {
        final propostaAggiornata = PropostaVotoResponse(
          id: _proposteCorrenti[propostaIndex].id,
          libroProposto: _proposteCorrenti[propostaIndex].libroProposto,
          meseVotazione: _proposteCorrenti[propostaIndex].meseVotazione,
          dataCreazione: _proposteCorrenti[propostaIndex].dataCreazione,
          numVoti: _proposteCorrenti[propostaIndex].numVoti - 1,
        );
        _proposteCorrenti[propostaIndex] = propostaAggiornata;
      }
      
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nella rimozione del voto: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Carica proposte storiche (mesi precedenti)
  Future<void> caricaProposteStoriche(String mese) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      _proposteStoriche = await _propostaVotoService.getProposteByMese(meseVotazione: mese);
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento delle proposte storiche: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Seleziona una proposta
  void selezionaProposta(PropostaVotoResponse proposta) 
  {
    _propostaSelezionata = proposta;
    notifyListeners();
  }

  // Deseleziona la proposta corrente
  void deselezionaProposta()
  {
    _propostaSelezionata = null;
    notifyListeners();
  }

  // Verifica se un libro è già stato proposto questo mese
  bool libroGiaProposto(int libroId) 
  {
    return _proposteCorrenti.any((proposta) => proposta.libroProposto.id == libroId);
  }

  // Ordina le proposte per numero di voti (discendente)
  void ordinaPropostePerVoti() 
  {
    _proposteCorrenti.sort((a, b) => b.numVoti.compareTo(a.numVoti));
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
    _proposteCorrenti = [];
    _proposteStoriche = [];
    _votiUtenteCorrente = [];
    _propostaSelezionata = null;
    _vincitoreMeseCorrente = null;
    _setError(null);
    _setLoading(false);
    notifyListeners();
  }
}