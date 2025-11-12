import 'dart:convert';
import 'package:http/http.dart' as http;

class PropostaVotoRepository 
{
  final http.Client client;
  final String baseUrl;

  PropostaVotoRepository({
    required this.baseUrl,
    required http.Client client,
  }) : client = client;

  Future<http.Response> createProposta(Map<String, dynamic> requestBody) async 
  {
    final url = Uri.parse('$baseUrl/api/proposte');
    
    return client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<http.Response> findById(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/proposte/$id');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> getWinnerProposta(String meseVotazione) async 
  {
    final url = Uri.parse('$baseUrl/api/proposte/vincitore/$meseVotazione');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> getProposteByMese(String meseVotazione) async 
  {
    final url = Uri.parse('$baseUrl/api/proposte/mese/$meseVotazione');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> voteForProposta(Map<String, dynamic> requestBody) async 
  {
    final url = Uri.parse('$baseUrl/api/proposte/voti');
    
    return client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<http.Response> updateProposta({
    required int id,
    required Map<String, dynamic> requestBody,
  }) async 
  {
    final url = Uri.parse('$baseUrl/api/proposte/$id');
    
    return client.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<http.Response> deleteProposta(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/proposte/$id');
    
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