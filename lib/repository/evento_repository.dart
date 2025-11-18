import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/EventoRequest.dart';
import '../models/EventoResponse.dart';

class EventoRepository 
{
  final String baseUrl;
  final String? token;

  EventoRepository({required this.baseUrl, this.token});

  Future<List<EventoResponse>> getEventiNelPeriodo(
      DateTime inizio, DateTime fine) async 
    {
    final response = await http.get(
      Uri.parse('$baseUrl/api/eventi?inizio=${inizio.toIso8601String()}&fine=${fine.toIso8601String()}'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) 
    {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => EventoResponse.fromJson(json)).toList();
    } 
    else 
    {
      throw Exception('Failed to load events: ${response.statusCode}');
    }
  }

  Future<EventoResponse> creaEvento(EventoRequest evento) async 
  {
    final response = await http.post(
      Uri.parse('$baseUrl/api/eventi'),
      headers: _getHeaders(),
      body: json.encode(evento.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) 
    {
      return EventoResponse.fromJson(json.decode(response.body));
    } 
    else 
    {
      throw Exception('Failed to create event: ${response.statusCode}');
    }
  }

  Future<EventoResponse> aggiornaEvento(int id, EventoRequest evento) async 
  {
    final response = await http.put(
      Uri.parse('$baseUrl/api/eventi/$id'),
      headers: _getHeaders(),
      body: json.encode(evento.toJson()),
    );

    if (response.statusCode == 200) 
    {
      return EventoResponse.fromJson(json.decode(response.body));
    } 
    else 
    {
      throw Exception('Failed to update event: ${response.statusCode}');
    }
  }

  Future<void> eliminaEvento(int id) async 
  {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/eventi/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode != 200 && response.statusCode != 204) 
    {
      throw Exception('Failed to delete event: ${response.statusCode}');
    }
  }

  Future<EventoResponse?> getProssimaVotazione() async 
  {
    final response = await http.get(
      Uri.parse('$baseUrl/api/eventi/prossima-votazione'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) 
    {
      return EventoResponse.fromJson(json.decode(response.body));
    } 
    else if (response.statusCode == 204) 
    {
      return null;
    } 
    else 
    {
      throw Exception('Failed to load next vote: ${response.statusCode}');
    }
  }

  Future<EventoResponse?> getProssimaDiscussione() async 
  {
    final response = await http.get(
      Uri.parse('$baseUrl/api/eventi/prossima-discussione'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) 
    {
      return EventoResponse.fromJson(json.decode(response.body));
    } 
    else if (response.statusCode == 204) 
    {
      return null;
    } 
    else 
    {
      throw Exception('Failed to load next discussion: ${response.statusCode}');
    }
  }

  Future<EventoResponse> getEventoById(int id) async 
  {
    final response = await http.get(
      Uri.parse('$baseUrl/api/eventi/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) 
    {
      return EventoResponse.fromJson(json.decode(response.body));
    } 
    else 
    {
      throw Exception('Failed to load event: ${response.statusCode}');
    }
  }

  Map<String, String> _getHeaders() 
  {
    final headers = 
    {
      'Content-Type': 'application/json',
    };
    
    if (token != null) 
    {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}