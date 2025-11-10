import 'package:flutter/foundation.dart';
import 'package:gld_raccoglitori/models/CommentoPaginaRequestModel.dart';
import 'package:gld_raccoglitori/models/commento_pagina_response.dart';
import 'package:gld_raccoglitori/services/commenti_api_service.dart';

class CommentiViewModel extends ChangeNotifier 
{
  final CommentiApiService _commentiService;

  // Stato dell'applicazione
  List<CommentoPaginaResponse> _commenti = [];
  List<CommentoPaginaResponse> _commentiUtente = [];
  CommentoPaginaResponse? _commentoSelezionato;
  bool _isLoading = false;
  String? _error;
  int? _letturaCorrenteId;
  int? _paginaCorrente;

  // Costruttore
  CommentiViewModel(this._commentiService);

  // Getter per lo stato
  List<CommentoPaginaResponse> get commenti => _commenti;
  List<CommentoPaginaResponse> get commentiUtente => _commentiUtente;
  CommentoPaginaResponse? get commentoSelezionato => _commentoSelezionato;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get letturaCorrenteId => _letturaCorrenteId;
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

  // Carica commenti per lettura e pagina
  Future<void> caricaCommentiPerPagina({required int letturaCorrenteId,required int paginaRiferimento}) async 
  {
    _setLoading(true);
    _setError(null);
    _letturaCorrenteId = letturaCorrenteId;
    _paginaCorrente = paginaRiferimento;
    
    try
    {
      _commenti = await _commentiService.getCommentiByLetturaAndPagina(
        letturaCorrenteId: letturaCorrenteId,
        paginaRiferimento: paginaRiferimento,
      );
      _ordinaCommentiPerData(_commenti);
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento dei commenti: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Carica commenti di un utente specifico
  Future<void> caricaCommentiUtente(int utenteId) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      _commentiUtente = await _commentiService.getCommentiByAutore(utenteId);
      _ordinaCommentiPerData(_commentiUtente);
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento dei commenti dell\'utente: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Crea un nuovo commento
  Future<bool> creaCommento({
    required int letturaCorrenteId,
    required int paginaRiferimento,
    required String contenuto,
  }) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final request = CommentoPaginaRequestModel(
        letturaCorrenteId: letturaCorrenteId,
        paginaRiferimento: paginaRiferimento,
        contenuto: contenuto,
      );

      final nuovoCommento = await _commentiService.createCommento(request);
      
      // Aggiungi il commento alla lista corrente se è per la stessa pagina
      if (_letturaCorrenteId == letturaCorrenteId && _paginaCorrente == paginaRiferimento)
      {
        _commenti.add(nuovoCommento);
        _ordinaCommentiPerData(_commenti);
      }
      
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nella creazione del commento: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Aggiorna il contenuto di un commento
  Future<bool> aggiornaCommento({required int commentoId, required String nuovoContenuto}) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final commentoAggiornato = await _commentiService.updateCommentoContenuto(
        commentoId: commentoId,
        nuovoContenuto: nuovoContenuto,
      );
      
      // Aggiorna nella lista principale
      final index = _commenti.indexWhere((c) => c.id == commentoId);
      if (index != -1) 
      {
        _commenti[index] = commentoAggiornato;
      }
      
      // Aggiorna nella lista utente
      final indexUtente = _commentiUtente.indexWhere((c) => c.id == commentoId);
      if (indexUtente != -1) 
      {
        _commentiUtente[indexUtente] = commentoAggiornato;
      }
      
      // Aggiorna il commento selezionato se è quello
      if (_commentoSelezionato?.id == commentoId) 
      {
        _commentoSelezionato = commentoAggiornato;
      }
      
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nell\'aggiornamento del commento: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Elimina un commento
  Future<bool> eliminaCommento(int commentoId) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      await _commentiService.deleteCommento(commentoId);
      
      // Rimuovi dalle liste
      _commenti.removeWhere((c) => c.id == commentoId);
      _commentiUtente.removeWhere((c) => c.id == commentoId);
      
      // Se il commento selezionato è quello eliminato, reset
      if (_commentoSelezionato?.id == commentoId) 
      {
        _commentoSelezionato = null;
      }
      
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nell\'eliminazione del commento: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Ottieni un commento per ID
  Future<void> caricaCommentoPerId(int id) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      _commentoSelezionato = await _commentiService.getCommentoById(id);
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento del commento: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Metodi di utilità per la UI

  // Seleziona un commento
  void selezionaCommento(CommentoPaginaResponse commento) 
  {
    _commentoSelezionato = commento;
    notifyListeners();
  }

  // Deseleziona il commento corrente
  void deselezionaCommento() 
  {
    _commentoSelezionato = null;
    notifyListeners();
  }

  // Filtra commenti per utente (locale)
  List<CommentoPaginaResponse> commentiPerUtente(int utenteId) 
  {
    return _commenti.where((c) => c.utente == utenteId).toList();
  }

  // Pulisci gli errori
  void clearError() 
  {
    _setError(null);
  }

  // Reset dello stato
  void resetState() 
  {
    _commenti = [];
    _commentiUtente = [];
    _commentoSelezionato = null;
    _letturaCorrenteId = null;
    _paginaCorrente = null;
    _setError(null);
    _setLoading(false);
    notifyListeners();
  }

  // Metodo privato per ordinare i commenti per data
  void _ordinaCommentiPerData(List<CommentoPaginaResponse> commenti) 
  {
    commenti.sort((a, b) => b.dataCreazione.compareTo(a.dataCreazione));
  }
}