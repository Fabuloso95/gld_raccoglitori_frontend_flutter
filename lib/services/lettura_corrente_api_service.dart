import 'dart:convert';
import 'package:gld_raccoglitori/models/LetturaCorrenteRequestModel.dart';
import 'package:gld_raccoglitori/models/LetturaCorrenteUpdateRequestModel.dart';
import 'package:http/http.dart' as http;
import '../models/lettura_corrente__progress_response.dart';
import '../models/lettura_corrente_response.dart';

class LetturaCorrenteApiService 
{
  final String baseUrl;
  final String? authToken;

  LetturaCorrenteApiService({required this.baseUrl, this.authToken});

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

  // Crea una nuova lettura
  Future<LetturaCorrenteResponse> startReading(LetturaCorrenteRequestModel request) async 
  {
    final url = Uri.parse('$baseUrl/api/letture');
    
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return LetturaCorrenteResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nella creazione della nuova lettura');
    }
  }

  // Ottiene una lettura per ID
  Future<LetturaCorrenteResponse> getReadingById(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/letture/$id');
    
    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return LetturaCorrenteResponse.fromJson(responseData);
    }
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero della lettura corrente');
    }
  }

  // Ottiene i progessi della lettura corrente
  Future<List<LetturaCorrenteProgressResponse>> getBookProgressOverview({
    required int libroId,
  }) async 
  {
    final url = Uri.parse(
      '$baseUrl/api/letture/libro/$libroId/progressi'
    );
    
    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) 
    {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData
          .map((json) => LetturaCorrenteProgressResponse.fromJson(json))
          .toList();
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero dei progressi della lettura');
    }
  }

  // Ottiene le mie letture
  Future<List<LetturaCorrenteResponse>> getMyReadings() async 
  {
    final url = Uri.parse('$baseUrl/api/letture/me');
    
    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) 
    {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData
          .map((json) => LetturaCorrenteResponse.fromJson(json))
          .toList();
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero delle mie letture');
    }
  }

  // Aggiorna i progressi di una lettura
  Future<LetturaCorrenteResponse> updateProgress({
    required int id,
    required LetturaCorrenteUpdateRequestModel request,
  }) async 
  {
    final url = Uri.parse('$baseUrl/api/letture/$id/progress');

    final response = await http.put(
      url,
      headers: _headers,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return LetturaCorrenteResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'aggiornamento della lettura');
    }
  }

  // Aggiorna il completamento di una lettura
  Future<LetturaCorrenteResponse> completeReading({
    required int id,
  }) async 
  {
    final url = Uri.parse('$baseUrl/api/letture/$id/complete');

    final response = await http.put(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return LetturaCorrenteResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'aggiornamento del completamento di una lettura');
    }
  }

  // Elimina una lettura
  Future<void> deleteReading(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/letture/$id');
    
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
      throw Exception('Errore nell\'eliminazione della lettura corrente');
    }
  }
}