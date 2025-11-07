import 'dart:convert';
import 'package:http/http.dart' as http;

const String _baseUrl = "http://localhost:8080/api/auth";

class AuthRepository 
{
  final http.Client client;

  AuthRepository({http.Client? client}) : client = client ?? http.Client();

  Future<http.Response> login({
    required String usernameOrEmail,
    required String password,
  }) async 
  {
    final url = Uri.parse('$_baseUrl/login');
    
    return client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      }),
    );
  }

  Future<http.Response> register({
    required String username,
    required String email,
    required String password,
    required String nome,
    required String cognome,
  }) async 
  {
    final url = Uri.parse('$_baseUrl/register');
    
    return client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
        'nome': nome,
        'cognome': cognome,
      }),
    );
  }

  Future<http.Response> refreshToken(String refreshToken) async 
  {
    final url = Uri.parse('$_baseUrl/refresh');
    
    return client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refreshToken': refreshToken}),
    );
  }

  Future<http.Response> logout(String refreshToken) async 
  {
    final url = Uri.parse('$_baseUrl/logout');
    
    return client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refreshToken': refreshToken}),
    );
  }

  Map<String, dynamic>? decodeJwt(String token) 
  {
    try 
    {
      final parts = token.split('.');
      if (parts.length != 3) 
      {
        throw const FormatException('Token non valido (non 3 parti)');
      }
      final payload = parts[1];
      final normalizedPayload = base64Url.decode(base64Url.normalize(payload));
      return json.decode(utf8.decode(normalizedPayload));
    } 
    catch (e) 
    {
      return null;
    }
  }

  bool isTokenExpired(String token) 
  {
    final payload = decodeJwt(token);
    if (payload == null || !payload.containsKey('exp')) 
    {
      return true;
    }

    final expirationDate = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000,);
    
    return expirationDate
        .subtract(const Duration(minutes: 1))
        .isBefore(DateTime.now());
  }

  int? getUserIdFromToken(String token) 
  {
    final payload = decodeJwt(token);
    return payload?['userId'] as int?;
  }

  void dispose() {client.close();}
}