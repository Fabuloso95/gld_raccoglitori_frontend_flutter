import 'dart:convert';
import 'package:http/http.dart' as http;

class LetturaCorrenteRepository 
{
  final http.Client client;
  final String baseUrl;

  LetturaCorrenteRepository({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<http.Response> startReading(Map<String, dynamic> requestBody) async 
  {
    final url = Uri.parse('$baseUrl/api/letture');
    
    return client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<http.Response> getReadingById(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/letture/$id');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> getBookProgressOverview(int libroId) async 
  {
    final url = Uri.parse('$baseUrl/api/letture/libro/$libroId/progressi');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> getMyReadings() async 
  {
    final url = Uri.parse('$baseUrl/api/letture/me');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> updateProgress({
    required int id,
    required Map<String, dynamic> requestBody,
  }) async 
  {
    final url = Uri.parse('$baseUrl/api/letture/$id/progress');
    
    return client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<http.Response> completeReading(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/letture/$id/complete');
    
    return client.put(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> deleteReading(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/letture/$id');
    
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