import 'dart:convert';
import 'package:http/http.dart' as http;

class MessaggioChatRepository 
{
  final http.Client client;
  final String baseUrl;

  MessaggioChatRepository({
    required this.baseUrl,
    required http.Client client,
  }) : client = client;

  Future<http.Response> sendMessage(Map<String, dynamic> requestBody) async 
  {
    final url = Uri.parse('$baseUrl/api/chat');
    
    return client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<http.Response> getGroupChatHistory(String gruppoID) async 
  {
    final url = Uri.parse('$baseUrl/api/chat/gruppo/$gruppoID');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> getPrivateChatHistory(int altroUtenteId) async 
  {
    final url = Uri.parse('$baseUrl/api/chat/privata/$altroUtenteId');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> deleteMessage(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/chat/$id');
    
    return client.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  void dispose() 
  {
    client.close();
  }
}