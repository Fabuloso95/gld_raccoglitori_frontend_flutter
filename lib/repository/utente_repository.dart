import 'dart:convert';
import 'package:http/http.dart' as http;

class UtenteRepository 
{
  final http.Client client;
  final String baseUrl;

  UtenteRepository({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<http.Response> createUtente(Map<String, dynamic> requestBody) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti');
    
    return client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<http.Response> getAllUtenti() async 
  {
    final url = Uri.parse('$baseUrl/api/utenti');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> getUtenteById(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/$id');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> updateUtente({
    required int id,
    required Map<String, dynamic> requestBody,
  }) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/$id');
    
    return client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<http.Response> deleteUtente(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/$id');
    
    return client.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> attivaUtente(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/$id/attiva');
    
    return client.patch(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> disattivaUtente(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/$id/disattiva');
    
    return client.patch(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> cambiaRuolo({
    required int id,
    required String nuovoRuolo,
  }) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/$id/ruolo?nuovoRuolo=${Uri.encodeComponent(nuovoRuolo)}');
    
    return client.patch(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> searchUtenti(String term) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/cerca?term=${Uri.encodeComponent(term)}');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> findByRuolo(String ruolo) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/filtra/ruolo?ruolo=${Uri.encodeComponent(ruolo)}');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> forgotPassword(String email) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/password/dimenticata?email=${Uri.encodeComponent(email)}');
    
    return client.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> resetPassword({
    required String token,
    required String nuovaPassword,
  }) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/password/reset?token=${Uri.encodeComponent(token)}&nuovaPassword=${Uri.encodeComponent(nuovaPassword)}');
    
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