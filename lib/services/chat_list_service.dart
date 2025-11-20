import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'messaggio_chat_api_service.dart';
import '../models/chat_preview.dart';
import '../models/messaggio_chat_response.dart';

class ChatListService with ChangeNotifier 
{
  final MessaggioChatApiService _chatService;
  final AuthService _authService;
  
  List<ChatPreview> _chats = [];
  bool _isLoading = false;
  String? _error;

  List<ChatPreview> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ChatListService({
    required MessaggioChatApiService chatService,
    required AuthService authService,
  })  : _chatService = chatService,
        _authService = authService;

  Future<void> caricaChat() async 
  {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try 
    {
      final currentUserId = _authService.currentUserId;
      if (currentUserId == null) 
      {
        throw Exception('Utente non autenticato');
      }

      final List<ChatPreview> chatList = [];

      await _caricaChatGruppiReali(chatList, currentUserId);
      await _caricaChatPrivateReali(chatList, currentUserId);

      chatList.sort((a, b) 
      {
        if (a.dataUltimoMessaggio == null) return 1;
        if (b.dataUltimoMessaggio == null) return -1;
        return b.dataUltimoMessaggio!.compareTo(a.dataUltimoMessaggio!);
      });

      _chats = chatList;
    } 
    catch (e) 
    {
      _error = 'Errore nel caricamento delle chat: $e';
    } 
    finally 
    {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _caricaChatGruppiReali(List<ChatPreview> chatList, int currentUserId) async 
  {
    final gruppiReali = 
    [
      _GruppoReale('gruppo-lettura-2024', 'Gruppo Lettura 2024'),
      _GruppoReale('club-del-libro', 'Club del Libro'),
    ];

    for (final gruppo in gruppiReali) 
    {
      try 
      {
        final messaggi = await _chatService.getGroupChatHistory(gruppo.id);
        
        if (messaggi.isNotEmpty) 
        {
          final ultimoMessaggio = messaggi.last;
          final messaggiNonLetti = _calcolaMessaggiNonLettiGruppo(messaggi, currentUserId);
          
          chatList.add(ChatPreview(
            gruppoId: gruppo.id,
            tipoChat: 'GRUPPO',
            titolo: gruppo.nome,
            ultimoMessaggio: ultimoMessaggio.contenuto,
            dataUltimoMessaggio: ultimoMessaggio.dataInvio,
            messaggiNonLetti: messaggiNonLetti,
          ));
        } 
        else 
        {
          chatList.add(ChatPreview(
            gruppoId: gruppo.id,
            tipoChat: 'GRUPPO',
            titolo: gruppo.nome,
            ultimoMessaggio: 'Nessun messaggio ancora',
            dataUltimoMessaggio: null,
            messaggiNonLetti: 0,
          ));
        }
      } 
      catch (e) 
      {
        print('Errore nel caricamento del gruppo ${gruppo.nome}: $e');
      }
    }
  }

  Future<void> _caricaChatPrivateReali(List<ChatPreview> chatList, int currentUserId) async 
  {
    try 
    {
      final utentiConCuiChattare = [1, 2];
      
      for (final utenteId in utentiConCuiChattare) 
      {
        try 
        {
          final messaggi = await _chatService.getPrivateChatHistory(altroUtenteId: utenteId);
          
          if (messaggi.isNotEmpty) 
          {
            final ultimoMessaggio = messaggi.last;
            final messaggiNonLetti = _calcolaMessaggiNonLettiPrivata(messaggi, currentUserId);
            final nomeUtente = ultimoMessaggio.mittente.id == utenteId 
                ? ultimoMessaggio.mittente.username 
                : 'Utente $utenteId';
            
            chatList.add(ChatPreview(
              altroUtenteId: utenteId,
              tipoChat: 'PRIVATA',
              titolo: nomeUtente,
              ultimoMessaggio: ultimoMessaggio.contenuto,
              dataUltimoMessaggio: ultimoMessaggio.dataInvio,
              messaggiNonLetti: messaggiNonLetti,
            ));
          }
        } 
        catch (e) 
        {
          print('Errore nel caricamento chat privata con utente $utenteId: $e');
        }
      }
    } 
    catch (e) 
    {
      print('Errore nel caricamento chat private: $e');
    }
  }

  int _calcolaMessaggiNonLettiGruppo(List<MessaggioChatResponse> messaggi, int currentUserId) 
  {
    int ultimoMessaggioUtenteIndex = -1;
    
    for (int i = messaggi.length - 1; i >= 0; i--) 
    {
      if (messaggi[i].mittente.id == currentUserId) 
      {
        ultimoMessaggioUtenteIndex = i;
        break;
      }
    }
    
    if (ultimoMessaggioUtenteIndex == -1) 
    {
      return messaggi.length;
    }
    
    return messaggi.length - ultimoMessaggioUtenteIndex - 1;
  }

  int _calcolaMessaggiNonLettiPrivata(List<MessaggioChatResponse> messaggi, int currentUserId) 
  {
    int ultimoMessaggioUtenteIndex = -1;
    
    for (int i = messaggi.length - 1; i >= 0; i--) 
    {
      if (messaggi[i].mittente.id == currentUserId) 
      {
        ultimoMessaggioUtenteIndex = i;
        break;
      }
    }
    
    if (ultimoMessaggioUtenteIndex == -1) 
    {
      return messaggi.length;
    }
    
    return messaggi.length - ultimoMessaggioUtenteIndex - 1;
  }

  void segnaComeLetta(String gruppoId) 
  {
    final index = _chats.indexWhere((chat) => chat.gruppoId == gruppoId);
    
    if (index != -1 && _chats[index].messaggiNonLetti > 0) 
    {
      _chats[index] = ChatPreview(
        gruppoId: _chats[index].gruppoId,
        altroUtenteId: _chats[index].altroUtenteId,
        tipoChat: _chats[index].tipoChat,
        titolo: _chats[index].titolo,
        ultimoMessaggio: _chats[index].ultimoMessaggio,
        dataUltimoMessaggio: _chats[index].dataUltimoMessaggio,
        messaggiNonLetti: 0,
      );
      notifyListeners();
    }
  }

  void segnaPrivataComeLetta(int utenteId) 
  {
    final index = _chats.indexWhere((chat) => chat.altroUtenteId == utenteId);
    
    if (index != -1 && _chats[index].messaggiNonLetti > 0) 
    {
      _chats[index] = ChatPreview(
        gruppoId: _chats[index].gruppoId,
        altroUtenteId: _chats[index].altroUtenteId,
        tipoChat: _chats[index].tipoChat,
        titolo: _chats[index].titolo,
        ultimoMessaggio: _chats[index].ultimoMessaggio,
        dataUltimoMessaggio: _chats[index].dataUltimoMessaggio,
        messaggiNonLetti: 0,
      );
      notifyListeners();
    }
  }

  void aggiorna() 
  {
    caricaChat();
  }
}

class _GruppoReale 
{
  final String id;
  final String nome;

  const _GruppoReale(this.id, this.nome);
}