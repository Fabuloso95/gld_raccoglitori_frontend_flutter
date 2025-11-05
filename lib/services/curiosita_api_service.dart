import 'dart:convert';
import 'package:gld_raccoglitori/models/CuriositaRequestModel.dart';
import 'package:http/http.dart' as http;
import '../models/curiosita_response.dart';

class CuriositaApiService 
{
  final String baseUrl;
  final String? authToken;

  CuriositaApiService({required this.baseUrl, this.authToken});

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
      case 500:
        throw Exception('Errore interno del server: ${response.body}');
      default:
        throw Exception('Errore ${response.statusCode}: ${response.body}');
    }
  }

  // Crea una nuova curiosità
  Future<CuriositaResponse> createCuriosita(CuriositaRequestModel request) async 
  {
    final url = Uri.parse('$baseUrl/api/curiosita');
    
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return CuriositaResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nella creazione della curiosità');
    }
  }

  // Ottiene una curiosità per ID
  Future<CuriositaResponse> getCuriositaById(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/curiosita/$id');
    
    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return CuriositaResponse.fromJson(responseData);
    }
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero della curiosità');
    }
  }

  // Ottiene una curiosità per libro
  Future<List<CuriositaResponse>> getCuriositaByLibro({
    required int libroId,
  }) async 
  {
    final url = Uri.parse(
      '$baseUrl/api/curiosita/libro/$libroId'
    );
    
    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) 
    {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData
          .map((json) => CuriositaResponse.fromJson(json))
          .toList();
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero delle curiosità');
    }
  }

  // Ottiene una curiosità tramite libro e pagina
  Future<List<CuriositaResponse>> getCuriositaByLibroAndPagina(int libroId, int paginaRiferimento) async 
  {
    final url = Uri.parse('$baseUrl/api/curiosita/libro/$libroId/pagina/$paginaRiferimento');
    
    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) 
    {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData
          .map((json) => CuriositaResponse.fromJson(json))
          .toList();
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero delle curiosità');
    }
  }

  // Aggiorna il contenuto di una curiosità
  Future<CuriositaResponse> updateCuriosita({
    required int id,
    required CuriositaRequestModel request,
  }) async 
  {
    final url = Uri.parse('$baseUrl/api/curiosita/$id');
    
    final response = await http.put(
      url,
      headers: _headers,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return CuriositaResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'aggiornamento della curiosità'); // Cambiato messaggio
    }
  }

  // Elimina un commento
  Future<void> deleteCuriosita(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/curiosita/$id');
    
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
      throw Exception('Errore nell\'eliminazione della curiosità');
    }
  }
}