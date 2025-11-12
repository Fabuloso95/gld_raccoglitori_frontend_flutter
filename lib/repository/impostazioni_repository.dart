import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/auth_client.dart';

class ImpostazioniRepository 
{
  final String baseUrl;
  final AuthService authService;
  final AuthClient _client;

  ImpostazioniRepository({
    required this.baseUrl,
    required this.authService,
  }) : _client = AuthClient(http.Client(), authService);

  Future<http.Response> getImpostazioniUtente(int utenteId) async 
  {
    final url = Uri.parse('$baseUrl/api/impostazioni/utente/$utenteId');
    
    // Usa direttamente il client HTTP normale se AuthClient dà problemi
    try {
      final response = await _client.get(url);
      // Se response è già una Response, ritornala direttamente
      return response;
          // Altrimenti converti da StreamedResponse
    } catch (e) {
      // Fallback: usa client HTTP diretto
      final client = http.Client();
      try {
        final response = await client.get(url);
        return response;
      } finally {
        client.close();
      }
    }
  }

  Future<http.Response> updateImpostazioni({
    required int utenteId,
    required Map<String, dynamic> requestBody,
  }) async 
  {
    final url = Uri.parse('$baseUrl/api/impostazioni/utente/$utenteId');
    
    try {
      final response = await _client.put(
        url,
        body: json.encode(requestBody),
      );
      
      return response;
        } catch (e) {
      // Fallback
      final client = http.Client();
      try {
        final response = await client.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );
        return response;
      } finally {
        client.close();
      }
    }
  }

  Future<http.Response> createImpostazioniDefault(int utenteId) async 
  {
    final url = Uri.parse('$baseUrl/api/impostazioni/utente/$utenteId/default');
    
    try {
      final response = await _client.post(url);
      
      return response;
        } catch (e) {
      // Fallback
      final client = http.Client();
      try {
        final response = await client.post(url);
        return response;
      } finally {
        client.close();
      }
    }
  }

  void dispose() 
  {
    _client.close();
  }
}