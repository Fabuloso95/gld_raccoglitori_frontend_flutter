import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gld_raccoglitori/models/MessaggioChatRequestModel.dart';
import 'package:gld_raccoglitori/models/messaggio_chat_response.dart';
import 'package:gld_raccoglitori/services/messaggio_chat_api_service.dart';

class ChatViewModel extends ChangeNotifier 
{
  final MessaggioChatApiService _chatService;

  // Stato dell'applicazione
  List<MessaggioChatResponse> _messaggiGruppo = [];
  List<MessaggioChatResponse> _messaggiPrivati = [];
  MessaggioChatResponse? _messaggioSelezionato;
  bool _isLoading = false;
  String? _error;
  String? _chatAttiva; // 'gruppo' o 'privata'
  String? _gruppoIdAttivo;
  int? _utenteIdAttivo;

  // Costruttore
  ChatViewModel(this._chatService);

  // Getter per lo stato
  List<MessaggioChatResponse> get messaggiGruppo => _messaggiGruppo;
  List<MessaggioChatResponse> get messaggiPrivati => _messaggiPrivati;
  MessaggioChatResponse? get messaggioSelezionato => _messaggioSelezionato;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get chatAttiva => _chatAttiva;
  String? get gruppoIdAttivo => _gruppoIdAttivo;
  int? get utenteIdAttivo => _utenteIdAttivo;

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

  void _notifyListenersSafe() 
  {
    if (WidgetsBinding.instance.lifecycleState != null) 
    {
      WidgetsBinding.instance.addPostFrameCallback((_) 
      {
        notifyListeners();
      });
    } 
    else 
    {
      notifyListeners();
    }
  }

  // Metodi per le operazioni di chat

  // Invia un messaggio
  Future<bool> inviaMessaggio(MessaggioChatRequestModel request) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final nuovoMessaggio = await _chatService.sendMessage(request);
      
      // Aggiungi il messaggio alla lista appropriata
      if (request.tipoChat == 'GRUPPO' && request.gruppoId != null) 
      {
        _messaggiGruppo.add(nuovoMessaggio);
        _ordinaMessaggiPerData(_messaggiGruppo);
      } 
      else if (request.tipoChat == 'PRIVATA' && request.destinatarioId != null) 
      {
        _messaggiPrivati.add(nuovoMessaggio);
        _ordinaMessaggiPerData(_messaggiPrivati);
      }
      
      _notifyListenersSafe();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nell\'invio del messaggio: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Carica storico chat di gruppo
  Future<void> caricaChatGruppo(String gruppoId) async 
  {
    _setLoading(true);
    _setError(null);
    _chatAttiva = 'gruppo';
    _gruppoIdAttivo = gruppoId;
    
    try 
    {
      _messaggiGruppo = await _chatService.getGroupChatHistory(gruppoId);
      _ordinaMessaggiPerData(_messaggiGruppo);
      _notifyListenersSafe();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento della chat di gruppo: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Carica storico chat privata
  Future<void> caricaChatPrivata(int altroUtenteId) async 
  {
    _setLoading(true);
    _setError(null);
    _chatAttiva = 'privata';
    _utenteIdAttivo = altroUtenteId;
    
    try 
    {
      _messaggiPrivati = await _chatService.getPrivateChatHistory(
        altroUtenteId: altroUtenteId,
      );
      _ordinaMessaggiPerData(_messaggiPrivati);
      _notifyListenersSafe();
    } 
    catch (e) 
    {
      _setError('Errore nel caricamento della chat privata: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Elimina un messaggio
  Future<bool> eliminaMessaggio(int id) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      await _chatService.deleteMessage(id);
      
      // Rimuovi il messaggio dalle liste
      _messaggiGruppo.removeWhere((msg) => msg.id == id);
      _messaggiPrivati.removeWhere((msg) => msg.id == id);
      
      // Se il messaggio selezionato è quello eliminato, reset
      if (_messaggioSelezionato?.id == id) 
      {
        _messaggioSelezionato = null;
      }
      
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nell\'eliminazione del messaggio: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Invia messaggio rapido (metodo di utilità)
  Future<bool> inviaMessaggioRapido({
    required String contenuto,
    required String tipoChat,
    String? gruppoId,
    int? destinatarioId,
  }) async 
  {
    final request = MessaggioChatRequestModel(
      gruppoId: gruppoId,
      tipoChat: tipoChat,
      destinatarioId: destinatarioId,
      contenuto: contenuto,
    );
    
    return await inviaMessaggio(request);
  }

  // Metodi di utilità per la UI

  // Seleziona un messaggio
  void selezionaMessaggio(MessaggioChatResponse messaggio) 
  {
    _messaggioSelezionato = messaggio;
    notifyListeners();
  }

  // Deseleziona il messaggio corrente
  void deselezionaMessaggio() 
  {
    _messaggioSelezionato = null;
    notifyListeners();
  }

  // Ottieni i messaggi correnti in base al tipo di chat attiva
  List<MessaggioChatResponse> get messaggiCorrenti 
  {
    if (_chatAttiva == 'gruppo') 
    {
      return _messaggiGruppo;
    } 
    else if (_chatAttiva == 'privata') 
    {
      return _messaggiPrivati;
    }
    return [];
  }

  // Aggiungi un messaggio in tempo reale (per WebSocket)
  void aggiungiMessaggioInTempoReale(MessaggioChatResponse messaggio) 
  {
    if (messaggio.tipoChat == 'GRUPPO' && 
        _chatAttiva == 'gruppo' && 
        messaggio.gruppoId == _gruppoIdAttivo) 
    {
      _messaggiGruppo.add(messaggio);
      _ordinaMessaggiPerData(_messaggiGruppo);
    } 
    else if (messaggio.tipoChat == 'PRIVATA' && 
               _chatAttiva == 'privata' && 
               messaggio.destinatario?.id == _utenteIdAttivo) 
    {
      _messaggiPrivati.add(messaggio);
      _ordinaMessaggiPerData(_messaggiPrivati);
    }
    _notifyListenersSafe();
  }

  // Pulisci gli errori
  void clearError() 
  {
    _setError(null);
  }

  // Reset dello stato
  void resetState() 
  {
    _messaggiGruppo = [];
    _messaggiPrivati = [];
    _messaggioSelezionato = null;
    _chatAttiva = null;
    _gruppoIdAttivo = null;
    _utenteIdAttivo = null;
    _setError(null);
    _setLoading(false);
    notifyListeners();
  }

  // Metodo privato per ordinare i messaggi per data
  void _ordinaMessaggiPerData(List<MessaggioChatResponse> messaggi) 
  {
    messaggi.sort((a, b) => a.dataInvio.compareTo(b.dataInvio));
  }
}