import 'dart:convert';
import 'package:gld_raccoglitori/models/PropostaVotoRequestModel.dart';
import 'package:gld_raccoglitori/models/VotoUtenteRequestModel.dart';
import 'package:gld_raccoglitori/models/proposta_voto_response.dart';
import 'package:gld_raccoglitori/models/voto_utente_response.dart';
import 'package:gld_raccoglitori/repository/proposta_voto_repository.dart';
import 'package:http/http.dart' as http;
import 'auth_client.dart';
import 'auth_service.dart';

class PropostaVotoApiService {
  final AuthClient _httpClient;
  final PropostaVotoRepository _repository;

  PropostaVotoApiService({
    required AuthService authService,
    required String baseUrl,
  })  : _httpClient = AuthClient(http.Client(), authService),
        _repository = PropostaVotoRepository(baseUrl: baseUrl);

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
      case 409:
        throw Exception('Conflitto: ${response.body}');
      case 500:
        throw Exception('Errore interno del server: ${response.body}');
      default:
        throw Exception('Errore ${response.statusCode}: ${response.body}');
    }
  }

  Future<PropostaVotoResponse> createProposta(PropostaVotoRequestModel request) async 
  {
    final response = await _repository.createProposta(request.toJson());

    if (response.statusCode == 201) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return PropostaVotoResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nella creazione della nuova proposta di voto');
    }
  }

  Future<PropostaVotoResponse> findById(int id) async 
  {
    final response = await _repository.findById(id);

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return PropostaVotoResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero della proposta di voto');
    }
  }

  Future<PropostaVotoResponse> getWinnerProposta(String meseVotazione) async 
  {
    final response = await _repository.getWinnerProposta(meseVotazione);

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return PropostaVotoResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero del vincitore della proposta di voto di $meseVotazione');
    }
  }

  Future<List<PropostaVotoResponse>> getProposteByMese({required String meseVotazione}) async 
  {
    final response = await _repository.getProposteByMese(meseVotazione);

    if (response.statusCode == 200) 
    {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData
          .map((json) => PropostaVotoResponse.fromJson(json))
          .toList();
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero delle proposte per il mese $meseVotazione');
    }
  }

  Future<VotoUtenteResponse> voteForProposta(VotoUtenteRequestModel request) async 
  {
    final response = await _repository.voteForProposta(request.toJson());

    if (response.statusCode == 201) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return VotoUtenteResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nella creazione del voto effettivo');
    }
  }

  Future<PropostaVotoResponse> updateProposta({
    required int id,
    required PropostaVotoRequestModel request,
  }) async 
  {
    final response = await _repository.updateProposta(
      id: id,
      requestBody: request.toJson(),
    );

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return PropostaVotoResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'aggiornamento della proposta di voto');
    }
  }

  Future<void> deleteProposta(int id) async 
  {
    final response = await _repository.deleteProposta(id);

    if (response.statusCode == 204) 
    {
      return;
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'eliminazione della proposta effettiva di voto');
    }
  }

  void dispose() 
  {
    _repository.dispose();
  }
}