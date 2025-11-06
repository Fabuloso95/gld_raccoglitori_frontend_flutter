import 'dart:convert';
import 'package:gld_raccoglitori/models/PropostaVotoRequestModel.dart';
import 'package:gld_raccoglitori/models/VotoUtenteRequestModel.dart';
import 'package:http/http.dart' as http;
import '../models/proposta_voto_response.dart';
import '../models/voto_utente_response.dart';

class PropostaVotoApiService 
{
  final String baseUrl;
  final String? authToken;

  PropostaVotoApiService({required this.baseUrl, this.authToken});

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
      case 409:
        throw Exception('Conflitto: ${response.body}');
      case 500:
        throw Exception('Errore interno del server: ${response.body}');
      default:
        throw Exception('Errore ${response.statusCode}: ${response.body}');
    }
  }

  // Crea una nuova proposta di voto
  Future<PropostaVotoResponse> createProposta(PropostaVotoRequestModel request) async 
  {
    final url = Uri.parse('$baseUrl/api/proposte');
    
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(request.toJson()),
    );

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

  // Ottiene una proposta voto tramite ID
  Future<PropostaVotoResponse> findById(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/proposte/$id');
    
    final response = await http.get(
      url,
      headers: _headers,
    );

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

  // Ottiene il vincitore della proposta di voto del mese
  Future<PropostaVotoResponse> getWinnerProposta(String meseVotazione) async 
  {
    final url = Uri.parse('$baseUrl/api/proposte/vincitore/$meseVotazione');
    
    final response = await http.get(
      url,
      headers: _headers,
    );

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

  // Ottiene le proposte per un dato mese
  Future<List<PropostaVotoResponse>> getProposteByMese({required String meseVotazione}) async 
  {
    final url = Uri.parse(
      '$baseUrl/api/proposte/mese/$meseVotazione'
    );
    
    final response = await http.get(
      url,
      headers: _headers,
    );

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

  // Crea una nuovo voto effettivo
  Future<VotoUtenteResponse> voteForProposta(VotoUtenteRequestModel request) async 
  {
    final url = Uri.parse('$baseUrl/api/proposte/voti');
    
    final response = await http.post(
      url,
      headers: _headers,
      body: json.encode(request.toJson()),
    );

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

  // Aggiorna la proposta di voto effettiva
  Future<PropostaVotoResponse> updateProposta({
    required int id,
    required PropostaVotoRequestModel request,
  }) async 
  {
    final url = Uri.parse('$baseUrl/api/proposte/$id');

    final response = await http.patch(
      url,
      headers: _headers,
      body: json.encode(request.toJson()),
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

  // Elimina una proposta di voto effettiva
  Future<void> deleteProposta(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/proposte/$id');
    
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
      throw Exception('Errore nell\'eliminazione della proposta effettiva di voto');
    }
  }
}