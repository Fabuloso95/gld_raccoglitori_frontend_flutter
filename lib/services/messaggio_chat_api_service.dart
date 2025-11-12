import 'dart:convert';
import 'package:gld_raccoglitori/models/MessaggioChatRequestModel.dart';
import 'package:gld_raccoglitori/models/messaggio_chat_response.dart';
import 'package:gld_raccoglitori/repository/messaggio_chat_repository.dart';
import 'package:http/http.dart' as http;
import 'auth_client.dart';
import 'auth_service.dart';

class MessaggioChatApiService 
{
  final MessaggioChatRepository _repository;

  MessaggioChatApiService({
    required AuthService authService,
    required String baseUrl,
  })  : _repository = MessaggioChatRepository(
        baseUrl: baseUrl,
        client: AuthClient(http.Client(), authService),
  );

  void _handleError(dynamic response) 
  {
    switch (response.statusCode) 
    {
      case 400:
        throw Exception('Richiesta non valida: ${response.body}');
      case 401:
        throw Exception('Non autorizzato: token di autenticazione mancante o non valido');
      case 403:
        throw Exception('Operazione non autorizzata');
      case 404:
        throw Exception('Risorsa non trovata');
      case 500:
        throw Exception('Errore interno del server: ${response.body}');
      default:
        throw Exception('Errore ${response.statusCode}: ${response.body}');
    }
  }

  Future<MessaggioChatResponse> sendMessage(MessaggioChatRequestModel request) async 
  {
    final response = await _repository.sendMessage(request.toJson());

    if (response.statusCode == 201) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return MessaggioChatResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'invio di un nuovo messaggio');
    }
  }

  Future<List<MessaggioChatResponse>> getGroupChatHistory(String gruppoID) async 
  {
    final response = await _repository.getGroupChatHistory(gruppoID);

    if (response.statusCode == 200) 
    {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData
          .map((json) => MessaggioChatResponse.fromJson(json))
          .toList();
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero dello storico della chat di gruppo');
    }
  }

  Future<List<MessaggioChatResponse>> getPrivateChatHistory({required int altroUtenteId}) async 
  {
    final response = await _repository.getPrivateChatHistory(altroUtenteId);

    if (response.statusCode == 200) 
    {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData
          .map((json) => MessaggioChatResponse.fromJson(json))
          .toList();
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero dello storico della chat privata');
    }
  }

  Future<void> deleteMessage(int id) async 
  {
    final response = await _repository.deleteMessage(id);

    if (response.statusCode == 204) 
    {
      return;
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'eliminazione di un messaggio dalla chat');
    }
  }

  void dispose() 
  {
    _repository.dispose();
  }
}