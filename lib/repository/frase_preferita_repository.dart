import 'dart:convert';
import 'package:http/http.dart' as http;

class FrasePreferitaRepository {
  final http.Client client;
  final String baseUrl;

  FrasePreferitaRepository({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<http.Response> saveFrase(Map<String, dynamic> requestBody) async 
  {
    final url = Uri.parse('$baseUrl/api/frasi-preferite');
    
    return client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<http.Response> getFrasePreferitaById(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/frasi-preferite/$id');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> getFrasiByLibro(int libroId) async 
  {
    final url = Uri.parse('$baseUrl/api/frasi-preferite/libro/$libroId');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> getMyFrasiPreferite() async 
  {
    final url = Uri.parse('$baseUrl/api/frasi-preferite/me');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> deleteFrase(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/frasi-preferite/$id');
    
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