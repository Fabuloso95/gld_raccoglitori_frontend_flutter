import 'dart:convert';
import 'package:gld_raccoglitori/models/impostazioni_request.dart';
import 'package:gld_raccoglitori/models/impostazioni_response.dart';
import 'package:gld_raccoglitori/repository/impostazioni_repository.dart';
import 'package:gld_raccoglitori/services/auth_service.dart';

class ImpostazioniApiService 
{
  final ImpostazioniRepository _repository;

  ImpostazioniApiService({
    required AuthService authService,
    required String baseUrl,
  }) : _repository = ImpostazioniRepository(
          baseUrl: baseUrl,
          authService: authService,
        );

  Future<ImpostazioniResponse> getImpostazioniUtente(int utenteId) async 
  {
    print('🔄 ImpostazioniApiService - getImpostazioniUtente per utente: $utenteId');
    try 
    {
      final response = await _repository.getImpostazioniUtente(utenteId);
      print('📡 ImpostazioniApiService - Response status: ${response.statusCode}');
      print('📡 ImpostazioniApiService - Response body: ${response.body}');
      
      if (response.statusCode == 200) 
      {
        final responseData = json.decode(response.body);
        return ImpostazioniResponse.fromJson(responseData);
      }
      _handleError(response);
      throw Exception('Errore nel recupero delle impostazioni');
    } 
    catch (e) 
    {
      print('❌ ImpostazioniApiService - Errore: $e');
      rethrow;
    }
  }

  Future<ImpostazioniResponse> updateImpostazioni({required int utenteId, required ImpostazioniRequest request}) async 
  {
    final response = await _repository.updateImpostazioni(
      utenteId: utenteId,
      requestBody: request.toJson(),
    );
    if (response.statusCode == 200) 
    {
      final responseData = json.decode(response.body);
      return ImpostazioniResponse.fromJson(responseData);
    }
    _handleError(response);
    throw Exception('Errore nell\'aggiornamento delle impostazioni');
  }

  Future<ImpostazioniResponse> createImpostazioniDefault(int utenteId) async 
  {
    final response = await _repository.createImpostazioniDefault(utenteId);
    if (response.statusCode == 201) 
    {
      final responseData = json.decode(response.body);
      return ImpostazioniResponse.fromJson(responseData);
    }
    _handleError(response);
    throw Exception('Errore nella creazione delle impostazioni default');
  }

  void _handleError(dynamic response) 
  {
    switch (response.statusCode) 
    {
      case 400:
        throw Exception('Richiesta non valida: ${response.body}');
      case 401:
        throw Exception('Non autorizzato');
      case 404:
        throw Exception('Impostazioni non trovate');
      case 500:
        throw Exception('Errore interno del server: ${response.body}');
      default:
        throw Exception('Errore ${response.statusCode}: ${response.body}');
    }
  }

  void dispose() 
  {
    _repository.dispose();
  }
}