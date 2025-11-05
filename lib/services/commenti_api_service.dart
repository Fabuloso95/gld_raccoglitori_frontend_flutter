import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/commento_pagina_response.dart';
import '../models/commentoPaginaRequestModel.dart';
import '../models/UpdateContenutoRequestModel.dart';

class CommentiApiService 
{
  final String baseUrl;
  final String? authToken;

  CommentiApiService({required this.baseUrl, this.authToken});

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

  // Crea un nuovo commento
  Future<CommentoPaginaResponse> createCommento(CommentoPaginaRequestModel request) async 
  {
    final url = Uri.parse('$baseUrl/api/commenti');
    
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return CommentoPaginaResponse.fromJson(responseData);
    } else {
      _handleError(response);
      throw Exception('Errore nella creazione del commento');
    }
  }

  // Ottiene un commento per ID
  Future<CommentoPaginaResponse> getCommentoById(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/commenti/$id');
    
    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return CommentoPaginaResponse.fromJson(responseData);
    }
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero del commento');
    }
  }

  // Ottiene i commenti per lettura e pagina
  Future<List<CommentoPaginaResponse>> getCommentiByLetturaAndPagina({
    required int letturaCorrenteId,
    required int paginaRiferimento,
  }) async 
  {
    final url = Uri.parse(
      '$baseUrl/api/commenti/lettura/$letturaCorrenteId/pagina/$paginaRiferimento'
    );
    
    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) 
    {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData
          .map((json) => CommentoPaginaResponse.fromJson(json))
          .toList();
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero dei commenti');
    }
  }

  // Ottiene i commenti per autore
  Future<List<CommentoPaginaResponse>> getCommentiByAutore(int utenteId) async 
  {
    final url = Uri.parse('$baseUrl/api/commenti/autore/$utenteId');
    
    final response = await http.get(
      url,
      headers: _headers,
    );

    if (response.statusCode == 200) 
    {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData
          .map((json) => CommentoPaginaResponse.fromJson(json))
          .toList();
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero dei commenti dell\'autore');
    }
  }

  // Aggiorna il contenuto di un commento
  Future<CommentoPaginaResponse> updateCommentoContenuto({
    required int commentoId,
    required String nuovoContenuto,
  }) async 
  {
    final url = Uri.parse('$baseUrl/api/commenti/$commentoId/contenuto');
    
    final requestBody = UpdateContenutoRequestModel(
      nuovoContenuto: nuovoContenuto,
    );

    final response = await http.patch(
      url,
      headers: _headers,
      body: json.encode(requestBody.toJson()),
    );

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return CommentoPaginaResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'aggiornamento del commento');
    }
  }

  // Elimina un commento
  Future<void> deleteCommento(int commentoId) async 
  {
    final url = Uri.parse('$baseUrl/api/commenti/$commentoId');
    
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
      throw Exception('Errore nell\'eliminazione del commento');
    }
  }
}