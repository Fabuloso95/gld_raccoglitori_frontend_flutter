import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/CommentoPaginaRequestModel.dart';
import '../models/UpdateContenutoRequestModel.dart';
import '../models/commento_pagina_response.dart';
import '../repository/commenti_repository.dart';
import 'auth_client.dart';
import 'auth_service.dart';

class CommentiApiService 
{
  final AuthClient _httpClient;
  final CommentiRepository _repository;

  CommentiApiService({
    required AuthService authService,
    required String baseUrl,
  })  : _httpClient = AuthClient(http.Client(), authService),
        _repository = CommentiRepository(baseUrl: baseUrl);

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

  Future<CommentoPaginaResponse> createCommento(CommentoPaginaRequestModel request) async 
  {
    final response = await _repository.createCommento(request.toJson());

    if (response.statusCode == 201) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return CommentoPaginaResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nella creazione del commento');
    }
  }

  Future<CommentoPaginaResponse> getCommentoById(int id) async 
  {
    final response = await _repository.getCommentoById(id);

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

  Future<List<CommentoPaginaResponse>> getCommentiByLetturaAndPagina({
    required int letturaCorrenteId,
    required int paginaRiferimento,
  }) async 
  {
    final response = await _repository.getCommentiByLetturaAndPagina(
      letturaCorrenteId: letturaCorrenteId,
      paginaRiferimento: paginaRiferimento,
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

  Future<List<CommentoPaginaResponse>> getCommentiByAutore(int utenteId) async 
  {
    final response = await _repository.getCommentiByAutore(utenteId);

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

  Future<CommentoPaginaResponse> updateCommentoContenuto({
    required int commentoId,
    required String nuovoContenuto,
  }) async 
  {
    final requestBody = UpdateContenutoRequestModel(
      nuovoContenuto: nuovoContenuto,
    );

    final response = await _repository.updateCommentoContenuto(
      commentoId: commentoId,
      requestBody: requestBody.toJson(),
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

  Future<void> deleteCommento(int commentoId) async 
  {
    final response = await _repository.deleteCommento(commentoId);

    if (response.statusCode == 204) 
    {
      return;
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'eliminazione del commento');
    }
  }

  void dispose() 
  {
    _repository.dispose();
  }
}