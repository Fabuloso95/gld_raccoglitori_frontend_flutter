import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/UtenteRequestModel.dart';
import '../models/UtenteUpdateRequestModel.dart';
import '../models/utente_response.dart';

class UtenteApiService 
{
  final String baseUrl;
  final String? authToken;

  UtenteApiService({required this.baseUrl, this.authToken});

  // Headers comuni per tutte le richieste
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  // Gestione errori
  void _handleError(http.Response response) {
    switch (response.statusCode) {
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

  // Crea un nuovo utente
  Future<UtenteResponse> createUtente(UtenteRequestModel request) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti');
    
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(request.toJson()),
    );

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

  // Ottiene tutti gli utenti
  Future<List<UtenteResponse>> getAllUtenti() async 
  {
    final url = Uri.parse('$baseUrl/api/utenti');
    
    final response = await http.get(
      url,
      headers: _headers,
    );

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

  // Ottiene un utente per ID
  Future<UtenteResponse> getUtenteById(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/$id');
    
    final response = await http.get(
      url,
      headers: _headers,
    );

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

  // Aggiorna un utente
  Future<UtenteResponse> updateUtente({required int id, required UtenteUpdateRequestModel request}) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/$id');

    final response = await http.put(
      url,
      headers: _headers,
      body: json.encode(request.toJson()),
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

  // Elimina un utente
  Future<void> deleteUtente(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/$id');
    
    final response = await http.delete(
      url,
      headers: _headers,
    );

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

  // Attiva un utente
  Future<UtenteResponse> attivaUtente(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/$id/attiva');

    final response = await http.patch(
      url,
      headers: _headers,
    );

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

  // Disattiva un utente
  Future<UtenteResponse> disattivaUtente(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/$id/disattiva');

    final response = await http.patch(
      url,
      headers: _headers,
    );

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

  // Cambia ruolo di un utente
  Future<UtenteResponse> cambiaRuolo({required int id, required String nuovoRuolo}) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/$id/ruolo?nuovoRuolo=$nuovoRuolo');

    final response = await http.patch(
      url,
      headers: _headers,
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

  // Cerca utenti per termine
  Future<List<UtenteResponse>> searchUtenti(String term) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/cerca?term=${Uri.encodeComponent(term)}');
    
    final response = await http.get(
      url,
      headers: _headers,
    );

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

  // Filtra utenti per ruolo
  Future<List<UtenteResponse>> findByRuolo(String ruolo) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/filtra/ruolo?ruolo=$ruolo');
    
    final response = await http.get(
      url,
      headers: _headers,
    );

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

  // Richiedi reset password
  Future<void> forgotPassword(String email) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/password/dimenticata?email=${Uri.encodeComponent(email)}');

    final response = await http.post(
      url,
      headers: _headers,
    );

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

  // Reset password con token
  Future<void> resetPassword({required String token, required String nuovaPassword}) async 
  {
    final url = Uri.parse('$baseUrl/api/utenti/password/reset?token=${Uri.encodeComponent(token)}&nuovaPassword=${Uri.encodeComponent(nuovaPassword)}');

    final response = await http.post(
      url,
      headers: _headers,
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
}