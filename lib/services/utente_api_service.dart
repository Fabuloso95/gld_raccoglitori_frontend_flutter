import 'dart:convert';
import 'package:gld_raccoglitori/models/UtenteRequestModel.dart';
import 'package:gld_raccoglitori/models/UtenteUpdateRequestModel.dart';
import 'package:gld_raccoglitori/models/utente_response.dart';
import 'package:gld_raccoglitori/repository/utente_repository.dart';
import 'package:http/http.dart' as http;
import 'auth_client.dart';
import 'auth_service.dart';

class UtenteApiService 
{
  final UtenteRepository _repository;

  UtenteApiService({
    required AuthService authService,
    required String baseUrl,
  })  : _repository = UtenteRepository(
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
      case 409:
        throw Exception('Conflitto: ${response.body}');
      case 500:
        throw Exception('Errore interno del server: ${response.body}');
      default:
        throw Exception('Errore ${response.statusCode}: ${response.body}');
    }
  }

  Future<UtenteResponse> createUtente(UtenteRequestModel request) async 
  {
    final response = await _repository.createUtente(request.toJson());

    if (response.statusCode == 201) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return UtenteResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nella creazione dell\'utente');
    }
  }

  Future<List<UtenteResponse>> getAllUtenti() async 
  {
    final response = await _repository.getAllUtenti();

    if (response.statusCode == 200) 
    {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData
          .map((json) => UtenteResponse.fromJson(json))
          .toList();
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero degli utenti');
    }
  }

  Future<UtenteResponse> getUtenteById(int id) async 
  {
    final response = await _repository.getUtenteById(id);

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return UtenteResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nel recupero dell\'utente');
    }
  }

  Future<UtenteResponse> updateUtente({
    required int id,
    required UtenteUpdateRequestModel request,
  }) async 
  {
    final response = await _repository.updateUtente(
      id: id,
      requestBody: request.toJson(),
    );

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return UtenteResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'aggiornamento dell\'utente');
    }
  }

  Future<void> deleteUtente(int id) async 
  {
    final response = await _repository.deleteUtente(id);

    if (response.statusCode == 204) 
    {
      return;
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'eliminazione dell\'utente');
    }
  }

  Future<UtenteResponse> attivaUtente(int id) async 
  {
    final response = await _repository.attivaUtente(id);

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return UtenteResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nell\'attivazione dell\'utente');
    }
  }

  Future<UtenteResponse> disattivaUtente(int id) async 
  {
    final response = await _repository.disattivaUtente(id);

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return UtenteResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nella disattivazione dell\'utente');
    }
  }

  Future<UtenteResponse> cambiaRuolo({
    required int id,
    required String nuovoRuolo,
  }) async 
  {
    final response = await _repository.cambiaRuolo(
      id: id,
      nuovoRuolo: nuovoRuolo,
    );

    if (response.statusCode == 200) 
    {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return UtenteResponse.fromJson(responseData);
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nel cambio ruolo dell\'utente');
    }
  }

  Future<List<UtenteResponse>> searchUtenti(String term) async 
  {
    final response = await _repository.searchUtenti(term);

    if (response.statusCode == 200) 
    {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData
          .map((json) => UtenteResponse.fromJson(json))
          .toList();
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nella ricerca degli utenti');
    }
  }

  Future<List<UtenteResponse>> findByRuolo(String ruolo) async 
  {
    final response = await _repository.findByRuolo(ruolo);

    if (response.statusCode == 200) 
    {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData
          .map((json) => UtenteResponse.fromJson(json))
          .toList();
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nel filtraggio degli utenti per ruolo');
    }
  }

  Future<void> forgotPassword(String email) async 
  {
    final response = await _repository.forgotPassword(email);

    if (response.statusCode == 202) 
    {
      return;
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nella richiesta di reset password');
    }
  }

  Future<void> resetPassword({
    required String token,
    required String nuovaPassword,
  }) async 
  {
    final response = await _repository.resetPassword(
      token: token,
      nuovaPassword: nuovaPassword,
    );

    if (response.statusCode == 200) 
    {
      return;
    } 
    else 
    {
      _handleError(response);
      throw Exception('Errore nel reset della password');
    }
  }

  void dispose() 
  {
    _repository.dispose();
  }
}