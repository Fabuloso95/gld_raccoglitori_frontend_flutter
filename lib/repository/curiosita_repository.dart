import 'dart:convert';
import 'package:http/http.dart' as http;

class CuriositaRepository 
{
  final http.Client client;
  final String baseUrl;

  CuriositaRepository({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<http.Response> createCuriosita(Map<String, dynamic> requestBody) async 
  {
    final url = Uri.parse('$baseUrl/api/curiosita');
    
    return client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<http.Response> getCuriositaById(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/curiosita/$id');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> getCuriositaByLibro(int libroId) async 
  {
    final url = Uri.parse('$baseUrl/api/curiosita/libro/$libroId');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> getCuriositaByLibroAndPagina({
    required int libroId,
    required int paginaRiferimento,
  }) async 
  {
    final url = Uri.parse('$baseUrl/api/curiosita/libro/$libroId/pagina/$paginaRiferimento');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> updateCuriosita({
    required int id,
    required Map<String, dynamic> requestBody,
  }) async 
  {
    final url = Uri.parse('$baseUrl/api/curiosita/$id');
    
    return client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<http.Response> deleteCuriosita(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/curiosita/$id');
    
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