import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/voto_utente_response.dart';

class VotoUtenteApiService 
{
  final String baseUrl;
  final String? authToken;

  VotoUtenteApiService({required this.baseUrl, this.authToken});

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

  // Ottiene un voto tramite ID
  Future<VotoUtenteResponse> findById(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/voti/$id');
    
    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return VotoUtenteResponse.fromJson(responseData);
    }
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero del voto');
    }
  }

  // Ottiene un voto se esiste
  Future<List<VotoUtenteResponse>> checkExistingVote({required String meseVotazione}) async 
  {
    final url = Uri.parse('$baseUrl/api/voti/check/mese/$meseVotazione');
    
    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) 
    {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData
          .map((json) => VotoUtenteResponse.fromJson(json))
          .toList();
    } 
    else if (response.statusCode == 204) 
    {
      return [];
    }
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero del voto esistente in base al mese');
    }
  }
}