import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/LetturaCorrenteRequestModel.dart';
import '../models/LetturaCorrenteUpdateRequestModel.dart';
import '../models/lettura_corrente__progress_response.dart';
import '../models/lettura_corrente_response.dart';
import '../repository/lettura_corrente_repository.dart';
import 'auth_service.dart';

class LetturaCorrenteApiService 
{
  final AuthService _authService;
  final String baseUrl;
  late LetturaCorrenteRepository _repository;

  LetturaCorrenteApiService({
    required AuthService authService,
    required this.baseUrl,
  }) : _authService = authService {
    // Crea il repository con l'AuthClient
    _repository = LetturaCorrenteRepository(
      baseUrl: baseUrl,
      authService: _authService, // Passa l'AuthService
    );
  }

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

  Future<LetturaCorrenteResponse> startReading(LetturaCorrenteRequestModel request) async 
  {
    final response = await _repository.startReading(request.toJson());

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

  Future<LetturaCorrenteResponse> getReadingById(int id) async 
  {
    final response = await _repository.getReadingById(id);

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

  Future<List<LetturaCorrenteProgressResponse>> getBookProgressOverview({
    required int libroId,
  }) async 
  {
    final response = await _repository.getBookProgressOverview(libroId);

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

  Future<List<LetturaCorrenteResponse>> getMyReadings() async 
  {
    final response = await _repository.getMyReadings();

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

  Future<LetturaCorrenteResponse> updateProgress({
    required int id,
    required LetturaCorrenteUpdateRequestModel request,
  }) async 
  {
    final response = await _repository.updateProgress(
      id: id,
      requestBody: request.toJson(),
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

  Future<LetturaCorrenteResponse> completeReading({
    required int id,
  }) async 
  {
    final response = await _repository.completeReading(id);

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

  Future<void> deleteReading(int id) async 
  {
    final response = await _repository.deleteReading(id);

    if (response.statusCode == 204) 
    {
      return;
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'eliminazione della lettura corrente');
    }
  }

  void dispose() 
  {
    _repository.dispose();
  }
}