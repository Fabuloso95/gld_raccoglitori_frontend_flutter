import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// URL di base del backend Spring Boot
const String _baseUrl = "http://localhost:8080/api/auth";

// Modello per la risposta di Autenticazione
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String username;
  final String ruolo;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.username,
    required this.ruolo,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      username: json['username'] ?? '',
      ruolo: json['ruolo'] ?? 'USER',
    );
  }
}

class AuthService with ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  String? _currentUsername;
  String? _currentRole;
  
  // STATO
  bool get isAuthenticated => _accessToken != null;
  String? get currentUsername => _currentUsername;
  String? get currentRole => _currentRole;

  AuthService() {
    // In un'app reale, qui caricheresti i token persistenti (es. da Secure Storage)
    _loadStoredTokens();
  }

  void _loadStoredTokens() {
    // SIMULAZIONE: in produzione userei flutter_secure_storage
    // Se il token è presente, aggiorna lo stato
    // ... logica di caricamento ...
    if (_accessToken != null) {
      notifyListeners();
    }
  }
  
  // Metodo helper per le chiamate API
  Future<http.Response> _post(String endpoint, Map<String, String> body) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    return http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
  }

  // --- LOGIN ---
  Future<String?> login(String usernameOrEmail, String password) async {
    try {
      final response = await _post('login', {
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      });

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));
        
        // Aggiorna lo stato
        _accessToken = authResponse.accessToken;
        _refreshToken = authResponse.refreshToken;
        _currentUsername = authResponse.username;
        _currentRole = authResponse.ruolo;
        
        // Notifica i widget che l'utente è loggato
        notifyListeners();
        return null; // Successo
      } else if (response.statusCode == 401) {
        return "Credenziali non valide.";
      } else {
        // Gestione errori del backend (es. validazione, 500)
        return "Errore di accesso: Status ${response.statusCode}";
      }
    } catch (e) {
      // Gestione errori di rete
      return "Errore di connessione al server: $e";
    }
  }

  // --- REGISTRAZIONE ---
  Future<String?> register({
    required String username,
    required String email,
    required String password,
    required String nome,
    required String cognome,
  }) async {
    try {
      final response = await _post('register', {
        'username': username,
        'email': email,
        'password': password,
        'nome': nome,
        'cognome': cognome,
      });

      if (response.statusCode == 201) {
        return null; // Registrazione avvenuta con successo
      } else if (response.statusCode == 409 || response.statusCode == 400) {
        // 409 Conflict per Utente già esistente, 400 per errori di validazione
        final body = json.decode(response.body);
        return body['message'] ?? 'Errore di registrazione. Username o Email già in uso.';
      } else {
        return "Errore di registrazione: Status ${response.statusCode}";
      }
    } catch (e) {
      return "Errore di connessione al server: $e";
    }
  }

  // --- LOGOUT ---
  void logout() {
    // In un'app reale dovresti anche chiamare l'endpoint /logout sul backend
    _accessToken = null;
    _refreshToken = null;
    _currentUsername = null;
    _currentRole = null;
    // Rimuovi i token dallo storage sicuro
    notifyListeners();
  }
}
