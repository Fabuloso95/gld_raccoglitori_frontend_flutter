import 'dart:convert';
import 'package:gld_raccoglitori/models/LibroRequestModel.dart';
import 'package:http/http.dart' as http;
import '../models/libro_response.dart';

class LibroApiService 
{
  final String baseUrl;
  final String? authToken;

  LibroApiService({required this.baseUrl, this.authToken});

  // Headers comuni per tutte le richieste
  Map<String, String> get _headers 
  {
    final headers = 
    {
      'Content-Type': 'application/json',
    };
    if (authToken != null) 
    {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  // Gestione errori
  void _handleError(http.Response response) 
  {
    switch (response.statusCode) 
    {
      case 400:
        throw Exception('Richiesta non valida: ${response.body}');
      case 401:
        throw Exception('Non autorizzato: token di autenticazione mancante o non valido');
      case 403:
        throw Exception('Operazione non autorizzata');
      case 404:
        throw Exception('Risorsa non trovata');
      case 409:
        throw Exception('Titolo duplicato: ${response.body}');
      case 500:
        throw Exception('Errore interno del server: ${response.body}');
      default:
        throw Exception('Errore ${response.statusCode}: ${response.body}');
    }
  }

  // Crea un nuovo libro
  Future<LibroResponse> creaLibro(LibroRequestModel request) async 
  {
    final url = Uri.parse('$baseUrl/api/libri');
    
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return LibroResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nella creazione di un nuovo libro');
    }
  }

  // Ottiene un libro tramite ID
  Future<LibroResponse> getLibroById(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/libri/$id');
    
    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return LibroResponse.fromJson(responseData);
    }
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero di un libro');
    }
  }

  // Ottiene tutti i libri o effettua una ricerca
Future<List<LibroResponse>> getAllLibriOrSearch({
  String? searchTerm,
}) async 
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
  
  final response = await http.get(
    url,
    headers: _headers,
  );

  if (response.statusCode == 200) 
  {
    final List<dynamic> responseData = json.decode(response.body);
    return responseData
        .map((json) => LibroResponse.fromJson(json))
        .toList();
  } 
  else 
  {
    _handleError(response);
    throw Exception('Errore nel recupero dei libri');
  }
}

  // Aggiorna i progressi di un libro
  Future<LibroResponse> aggiornaLibro({
    required int id,
    required LibroRequestModel request,
  }) async 
  {
    final url = Uri.parse('$baseUrl/api/libri/$id');

    final response = await http.put(
      url,
      headers: _headers,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return LibroResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'aggiornamento di un libro');
    }
  }

  // Elimina un libro
  Future<void> eliminaLibro(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/libri/$id');
    
    final response = await http.delete(
      url,
      headers: _headers,
    );

    if (response.statusCode == 204) 
    {
      return; // Successo - nessun contenuto
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'eliminazione di un libro');
    }
  }
}