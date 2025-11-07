import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_client.dart';
import 'auth_service.dart';

// URL di base per le risorse PROTETTE
const String _apiBaseUrl = "http://localhost:8080/api/raccoglitori"; 

// Modello di Dati (Raccoglitore)
class Raccoglitore 
{
  final int id;
  final String nome;
  final String cognome;

  Raccoglitore({required this.id, required this.nome, required this.cognome});

  factory Raccoglitore.fromJson(Map<String, dynamic> json) 
  {
    return Raccoglitore(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      cognome: json['cognome'] ?? '',
    );
  }
}

class RaccoglitoriApiService 
{
  final AuthClient _httpClient;

  RaccoglitoriApiService(AuthService authService) 
    : _httpClient = AuthClient(
        http.Client(), 
        authService,
      );

  // Chiamata API Protetta GET
  Future<List<Raccoglitore>> getElencoRaccoglitori() async 
  {
    final url = Uri.parse('$_apiBaseUrl/tutti');
    
    try 
    {
      // AuthClient aggiunge il token e gestisce il refresh in caso di 401
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) 
      {
        final List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
        return jsonList.map((json) => Raccoglitore.fromJson(json)).toList();
      } 
      else 
      {
        throw Exception('Errore nel caricamento dei raccoglitori: Status ${response.statusCode}');
      }
    } 
    on SocketException 
    {
      throw Exception('Errore di connessione: verifica il server o la rete.');
    } 
    catch (e) 
    {
      throw Exception('Errore di chiamata API protetta: ${e.toString()}');
    }
  }

  // Chiamata API Protetta POST
  Future<Raccoglitore> createRaccoglitore(String nome, String cognome) async 
  {
    final url = Uri.parse('$_apiBaseUrl/crea');
    
    try 
    {
      final response = await _httpClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'nome': nome, 'cognome': cognome}),
      );

      if (response.statusCode == 201) 
      {
        return Raccoglitore.fromJson(json.decode(response.body));
      } 
      else 
      {
        throw Exception('Creazione fallita: Status ${response.statusCode}');
      }
    } 
    on SocketException 
    {
      throw Exception('Errore di connessione: verifica il server o la rete.');
    } 
    catch (e) 
    {
      throw Exception('Errore durante la creazione del raccoglitore: ${e.toString()}');
    }
  }
}