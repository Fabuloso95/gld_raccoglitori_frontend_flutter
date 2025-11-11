import 'package:flutter/foundation.dart';
import 'package:gld_raccoglitori/models/PropostaVotoRequestModel.dart';
import 'package:gld_raccoglitori/models/VotoUtenteRequestModel.dart';
import 'package:gld_raccoglitori/models/proposta_voto_response.dart';
import 'package:gld_raccoglitori/services/proposta_voto_api_service.dart';
import 'package:gld_raccoglitori/view_models/voto_utente_view_model.dart';

class PropostaVotoViewModel extends ChangeNotifier 
{
  final PropostaVotoApiService _propostaVotoService;
  final VotoUtenteViewModel _votoUtenteViewModel;

  List<PropostaVotoResponse> _proposteCorrenti = [];
  List<PropostaVotoResponse> _proposteStoriche = [];
  PropostaVotoResponse? _propostaSelezionata;
  PropostaVotoResponse? _vincitoreMeseCorrente;
  bool _isLoading = false;
  String? _error;
  String _meseCorrente = '';

  PropostaVotoViewModel(this._propostaVotoService, this._votoUtenteViewModel) 
  {
    _caricaMeseCorrente();
  }

  List<PropostaVotoResponse> get proposteCorrenti => _proposteCorrenti;
  List<PropostaVotoResponse> get proposteStoriche => _proposteStoriche;
  PropostaVotoResponse? get propostaSelezionata => _propostaSelezionata;
  PropostaVotoResponse? get vincitoreMeseCorrente => _vincitoreMeseCorrente;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get meseCorrente => _meseCorrente;
  
  bool haVotatoPerProposta(int propostaId) 
  {
    return _votoUtenteViewModel.haVotatoPerProposta(propostaId);
  }
  
  int get votiUtenteCorrente => _votoUtenteViewModel.votiUtenteCorrente.length;
  int get maxVotiConsentiti => 3;
  bool get puoVotareAncora => _votoUtenteViewModel.puoVotareAncora;

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

  void _caricaMeseCorrente() 
  {
    final now = DateTime.now();
    _meseCorrente = '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<void> caricaProposteMeseCorrente() async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      _proposteCorrenti = await _propostaVotoService.getProposteByMese(meseVotazione: _meseCorrente);
      await _votoUtenteViewModel.caricaVotiUtenteCorrente();
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

  Future<void> _caricaVincitoreMeseCorrente() async 
  {
    try
    {
      _vincitoreMeseCorrente = await _propostaVotoService.getWinnerProposta(_meseCorrente);
    } 
    catch (e) 
    {
      _vincitoreMeseCorrente = null;
    }
  }

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

  Future<bool> votaPerProposta(int propostaId) async 
  {
    if (!_votoUtenteViewModel.puoVotareAncora) 
    {
      _setError('Hai già raggiunto il massimo di 3 voti questo mese');
      return false;
    }

    if (_votoUtenteViewModel.haVotatoPerProposta(propostaId)) 
    {
      _setError('Hai già votato per questa proposta');
      return false;
    }

    _setLoading(true);
    _setError(null);
    
    try 
    {
      final request = VotoUtenteRequestModel(
        propostaVotoId: propostaId,
        meseVotazione: _meseCorrente,
      );
      
      final voto = await _propostaVotoService.voteForProposta(request);
      
      _votoUtenteViewModel.aggiungiVotoLocalmente(voto);
      
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

  Future<bool> rimuoviVoto(int propostaId) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      _votoUtenteViewModel.rimuoviVotoLocalmente(propostaId);
      
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

  void selezionaProposta(PropostaVotoResponse proposta) 
  {
    _propostaSelezionata = proposta;
    notifyListeners();
  }

  void deselezionaProposta() 
  {
    _propostaSelezionata = null;
    notifyListeners();
  }

  bool libroGiaProposto(int libroId) 
  {
    return _proposteCorrenti.any((proposta) => proposta.libroProposto.id == libroId);
  }

  void ordinaPropostePerVoti() 
  {
    _proposteCorrenti.sort((a, b) => b.numVoti.compareTo(a.numVoti));
    notifyListeners();
  }

  void clearError() 
  {
    _setError(null);
  }

  void resetState() 
  {
    _proposteCorrenti = [];
    _proposteStoriche = [];
    _propostaSelezionata = null;
    _vincitoreMeseCorrente = null;
    _setError(null);
    _setLoading(false);
    notifyListeners();
  }
}