import 'dart:convert';
import 'package:http/http.dart' as http;

class LibroRepository 
{
  final http.Client client;
  final String baseUrl;

  LibroRepository({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<http.Response> creaLibro(Map<String, dynamic> requestBody) async 
  {
    final url = Uri.parse('$baseUrl/api/libri');
    
    return client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<http.Response> getLibroById(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/libri/$id');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> getAllLibriOrSearch({String? searchTerm}) async 
  {
    final Uri url;
    
    if (searchTerm != null && searchTerm.isNotEmpty) 
    {
      url = Uri.parse('$baseUrl/api/libri?searchTerm=${Uri.encodeComponent(searchTerm)}');
    } 
    else
    {
      url = Uri.parse('$baseUrl/api/libri');
    }
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> aggiornaLibro({
    required int id,
    required Map<String, dynamic> requestBody,
  }) async 
  {
    final url = Uri.parse('$baseUrl/api/libri/$id');
    
    return client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
  }

  Future<http.Response> eliminaLibro(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/libri/$id');
    
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