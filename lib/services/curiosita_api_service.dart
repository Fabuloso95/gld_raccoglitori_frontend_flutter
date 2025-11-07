// services/curiosita_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/CuriositaRequestModel.dart';
import '../models/curiosita_response.dart';
import '../repository/curiosita_repository.dart';
import 'auth_client.dart';
import 'auth_service.dart';

class CuriositaApiService 
{
  final AuthClient _httpClient;
  final CuriositaRepository _repository;

  CuriositaApiService({
    required AuthService authService,
    required String baseUrl,
  })  : _httpClient = AuthClient(http.Client(), authService),
        _repository = CuriositaRepository(baseUrl: baseUrl);

  void _handleError(http.Response response) 
  {
    switch (response.statusCode) {
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

  Future<CuriositaResponse> createCuriosita(CuriositaRequestModel request) async 
  {
    final response = await _repository.createCuriosita(request.toJson());

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

  Future<CuriositaResponse> getCuriositaById(int id) async 
  {
    final response = await _repository.getCuriositaById(id);

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

  Future<List<CuriositaResponse>> getCuriositaByLibro({
    required int libroId,
  }) async 
  {
    final response = await _repository.getCuriositaByLibro(libroId);

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

  Future<List<CuriositaResponse>> getCuriositaByLibroAndPagina({
    required int libroId,
    required int paginaRiferimento,
  }) async 
  {
    final response = await _repository.getCuriositaByLibroAndPagina(
      libroId: libroId,
      paginaRiferimento: paginaRiferimento,
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

  Future<CuriositaResponse> updateCuriosita({
    required int id,
    required CuriositaRequestModel request,
  }) async 
  {
    final response = await _repository.updateCuriosita(
      id: id,
      requestBody: request.toJson(),
    );

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return CuriositaResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'aggiornamento della curiosità');
    }
  }

  Future<void> deleteCuriosita(int id) async 
  {
    final response = await _repository.deleteCuriosita(id);

    if (response.statusCode == 204) 
    {
      return;
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'eliminazione della curiosità');
    }
  }

  void dispose() 
  {
    _repository.dispose();
  }
}