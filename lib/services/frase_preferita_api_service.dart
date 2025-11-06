import 'dart:convert';
import 'package:gld_raccoglitori/models/FrasePreferitaRequestModel.dart';
import 'package:http/http.dart' as http;
import '../models/frase_preferita_response.dart';

class FrasePreferitaApiService 
{
  final String baseUrl;
  final String? authToken;

  FrasePreferitaApiService({required this.baseUrl, this.authToken});

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

  // Crea una nuova frase preferita
  Future<FrasePreferitaResponse> saveFrase(FrasePreferitaRequestModel request) async 
  {
    final url = Uri.parse('$baseUrl/api/frasi-preferite');
    
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return FrasePreferitaResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nella creazione della frase preferita');
    }
  }

  // Ottiene una frase preferita per ID
  Future<FrasePreferitaResponse> getFrasePreferitaById(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/frasi-preferite/$id');
    
    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return FrasePreferitaResponse.fromJson(responseData);
    }
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero della frase preferita');
    }
  }

  // Ottiene una frasi-preferita per libro
  Future<List<FrasePreferitaResponse>> getFrasiByLibro({
    required int libroId,
  }) async 
  {
    final url = Uri.parse(
      '$baseUrl/api/frasi-preferite/libro/$libroId'
    );
    
    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) 
    {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData
          .map((json) => FrasePreferitaResponse.fromJson(json))
          .toList();
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero delle frasi preferite');
    }
  }

  // Ottiene una frase preferita tramite libro e pagina
  Future<List<FrasePreferitaResponse>> getMyFrasiPreferite() async 
  {
    final url = Uri.parse('$baseUrl/api/frasi-preferite/me');
    
    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) 
    {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData
          .map((json) => FrasePreferitaResponse.fromJson(json))
          .toList();
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero delle mie frasi preferite');
    }
  }

  // Elimina un frase preferita
  Future<void> deleteFrase(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/frasi-preferite/$id');
    
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
      throw Exception('Errore nell\'eliminazione della frase preferita');
    }
  }
}