import 'dart:convert';
import 'package:http/http.dart' as http;

class CommentiRepository 
{
  final http.Client client;
  final String baseUrl;

  CommentiRepository({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<http.Response> createCommento(Map<String, dynamic> requestBody) async 
  {
    final url = Uri.parse('$baseUrl/api/commenti');
    
    return client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<http.Response> getCommentoById(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/commenti/$id');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> getCommentiByLetturaAndPagina({
    required int letturaCorrenteId,
    required int paginaRiferimento,
  }) async 
  {
    final url = Uri.parse(
      '$baseUrl/api/commenti/lettura/$letturaCorrenteId/pagina/$paginaRiferimento'
    );
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> getCommentiByAutore(int utenteId) async 
  {
    final url = Uri.parse('$baseUrl/api/commenti/autore/$utenteId');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> updateCommentoContenuto({
    required int commentoId,
    required Map<String, dynamic> requestBody,
  }) async 
  {
    final url = Uri.parse('$baseUrl/api/commenti/$commentoId/contenuto');
    
    return client.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<http.Response> deleteCommento(int commentoId) async 
  {
    final url = Uri.parse('$baseUrl/api/commenti/$commentoId');
    
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