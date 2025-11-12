import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/auth_client.dart';

class ImpostazioniRepository 
{
  final String baseUrl;
  final AuthService authService;
  late http.Client client;

  ImpostazioniRepository({
    required this.baseUrl,
    required this.authService,
  }) 
  {
    client = AuthClient(http.Client(), authService);
  }

  Future<http.Response> getImpostazioniUtente(int utenteId) async 
  {
    final url = Uri.parse('$baseUrl/api/impostazioni/utente/$utenteId');
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> updateImpostazioni({required int utenteId, required Map<String, dynamic> requestBody}) async 
  {
    final url = Uri.parse('$baseUrl/api/impostazioni/utente/$utenteId');
    return client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<http.Response> createImpostazioniDefault(int utenteId) async 
  {
    final url = Uri.parse('$baseUrl/api/impostazioni/utente/$utenteId');
    return client.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  void dispose() 
  {
    client.close();
  }
}