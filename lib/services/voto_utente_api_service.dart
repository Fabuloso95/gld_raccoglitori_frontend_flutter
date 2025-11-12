import 'dart:convert';
import 'package:gld_raccoglitori/models/voto_utente_response.dart';
import 'package:gld_raccoglitori/repository/voto_utente_repository.dart';
import 'package:http/http.dart' as http;
import 'auth_client.dart';
import 'auth_service.dart';

class VotoUtenteApiService 
{
  final VotoUtenteRepository _repository;

  VotoUtenteApiService({
    required AuthService authService,
    required String baseUrl,
  })  : _repository = VotoUtenteRepository(
        baseUrl: baseUrl,
        client: AuthClient(http.Client(), authService),
  );

  void _handleError(dynamic response) 
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

  Future<VotoUtenteResponse> findById(int id) async 
  {
    final response = await _repository.findById(id);

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

  Future<List<VotoUtenteResponse>> checkExistingVote({required String meseVotazione}) async 
  {
    final response = await _repository.checkExistingVote(meseVotazione);

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

  void dispose() 
  {
    _repository.dispose();
  }
}