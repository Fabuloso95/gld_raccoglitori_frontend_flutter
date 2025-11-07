import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/FrasePreferitaRequestModel.dart';
import '../models/frase_preferita_response.dart';
import '../repository/frase_preferita_repository.dart';
import 'auth_client.dart';
import 'auth_service.dart';

class FrasePreferitaApiService 
{
  final AuthClient _httpClient;
  final FrasePreferitaRepository _repository;

  FrasePreferitaApiService({
    required AuthService authService,
    required String baseUrl,
  })  : _httpClient = AuthClient(http.Client(), authService),
        _repository = FrasePreferitaRepository(baseUrl: baseUrl);

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

  Future<FrasePreferitaResponse> saveFrase(FrasePreferitaRequestModel request) async 
  {
    final response = await _repository.saveFrase(request.toJson());

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

  Future<FrasePreferitaResponse> getFrasePreferitaById(int id) async 
  {
    final response = await _repository.getFrasePreferitaById(id);

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

  Future<List<FrasePreferitaResponse>> getFrasiByLibro({
    required int libroId,
  }) async 
  {
    final response = await _repository.getFrasiByLibro(libroId);

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

  Future<List<FrasePreferitaResponse>> getMyFrasiPreferite() async 
  {
    final response = await _repository.getMyFrasiPreferite();

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

  Future<void> deleteFrase(int id) async 
  {
    final response = await _repository.deleteFrase(id);

    if (response.statusCode == 204) 
    {
      return;
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'eliminazione della frase preferita');
    }
  }

  void dispose() 
  {
    _repository.dispose();
  }
}