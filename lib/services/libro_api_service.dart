import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/LibroRequestModel.dart';
import '../models/libro_response.dart';
import '../repository/libro_repository.dart';
import 'auth_client.dart';
import 'auth_service.dart';

class LibroApiService 
{
  final AuthClient _httpClient;
  final LibroRepository _repository;

  LibroApiService({
    required AuthService authService,
    required String baseUrl,
  })  : _httpClient = AuthClient(http.Client(), authService),
        _repository = LibroRepository(baseUrl: baseUrl);

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

  Future<LibroResponse> creaLibro(LibroRequestModel request) async 
  {
    final response = await _repository.creaLibro(request.toJson());

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

  Future<LibroResponse> getLibroById(int id) async 
  {
    final response = await _repository.getLibroById(id);

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

  Future<List<LibroResponse>> getAllLibriOrSearch({
    String? searchTerm,
  }) async 
  {
    final response = await _repository.getAllLibriOrSearch(searchTerm: searchTerm);

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

  Future<LibroResponse> aggiornaLibro({
    required int id,
    required LibroRequestModel request,
  }) async 
  {
    final response = await _repository.aggiornaLibro(
      id: id,
      requestBody: request.toJson(),
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

  Future<void> eliminaLibro(int id) async 
  {
    final response = await _repository.eliminaLibro(id);

    if (response.statusCode == 204) 
    {
      return;
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'eliminazione di un libro');
    }
  }

  void dispose() 
  {
    _repository.dispose();
  }
}