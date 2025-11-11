import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gld_raccoglitori/services/auth_client.dart';
import 'package:gld_raccoglitori/services/auth_service.dart';

class ImpostazioniRepository {
  final AuthClient client;
  final String baseUrl;

  ImpostazioniRepository({
    required this.baseUrl,
    required AuthService authService,
  }) : client = AuthClient(http.Client(), authService);

  Future<http.Response> getImpostazioniUtente(int utenteId) async {
    final url = Uri.parse('$baseUrl/api/impostazioni/utente/$utenteId');
    return client.get(url);
  }

  Future<http.Response> updateImpostazioni({
    required int utenteId, 
    required Map<String, dynamic> requestBody
  }) async {
    final url = Uri.parse('$baseUrl/api/impostazioni/utente/$utenteId');
    return client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<http.Response> createImpostazioniDefault(int utenteId) async {
    final url = Uri.parse('$baseUrl/api/impostazioni/utente/$utenteId/default');
    return client.post(url);
  }

  void dispose() 
  {
    
  }
}