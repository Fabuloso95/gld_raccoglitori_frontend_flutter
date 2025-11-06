import 'dart:convert';
import 'package:gld_raccoglitori/models/MessaggioChatRequestModel.dart';
import 'package:http/http.dart' as http;
import '../models/messaggio_chat_response.dart';

class MessaggioChatApiService 
{
  final String baseUrl;
  final String? authToken;

  MessaggioChatApiService({required this.baseUrl, this.authToken});

  // Headers comuni per tutte le richieste
  Map<String, String> get _headers 
  {
    final headers = 
    {
      'Content-Type': 'application/json',
    };
    if (authToken != null) 
    {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  // Gestione errori
  void _handleError(http.Response response) 
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

  // Invia un nuovo messaggio 
  Future<MessaggioChatResponse> sendMessage(MessaggioChatRequestModel request) async 
  {
    final url = Uri.parse('$baseUrl/api/chat');
    
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(request.toJson()),
    );

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

  // Ottieni lo storico dei messaggi di una chat di gruppo
  Future<List<MessaggioChatResponse>> getGroupChatHistory(String gruppoID) async 
  {
    final url = Uri.parse('$baseUrl/api/chat/gruppo/$gruppoID');
    
    final response = await http.get(
      url,
      headers: _headers,
    );

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

  // Ottieni lo storico dei messaggi di una chat privata
  Future<List<MessaggioChatResponse>> getPrivateChatHistory({required int altroUtenteId}) async 
  {
    final url = Uri.parse(
      '$baseUrl/api/chat/privata/$altroUtenteId'
    );
    
    final response = await http.get(
      url,
      headers: _headers,
    );

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

  // Elimina il messaggio dalla chat
  Future<void> deleteMessage(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/chat/$id');
    
    final response = await http.delete(
      url,
      headers: _headers,
    );

    if (response.statusCode == 204) 
    {
      return; // Successo - nessun contenuto
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'eliminazione di un messaggio dalla chat');
    }
  }
}