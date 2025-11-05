import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

// URL di base del backend Spring Boot per l'autenticazione
const String _baseUrl = "http://localhost:8080/api/auth";

// Chiavi per FlutterSecureStorage
const String _accessTokenKey = 'accessToken';
const String _refreshTokenKey = 'refreshToken';
const String _usernameKey = 'username';
const String _roleKey = 'role';

// Modello per la risposta di Autenticazione (usato in Login e Refresh)
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

  factory AuthResponse.fromJson(Map<String, dynamic> json) 
  {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      username: json['username'] ?? '',
      ruolo: json['ruolo'] ?? 'USER',
    );
  }
}

class AuthService with ChangeNotifier 
{
  // Inizializzazione di FlutterSecureStorage
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Client HTTP dedicato per le chiamate PUBBLICHE (Login, Register, Refresh)
  // IMPORTANTE: Questo client NON ha intercettori.
  final http.Client _publicClient = http.Client();

  // Stato locale dell'autenticazione
  String? _accessToken;
  String? _refreshToken;
  String? _currentUsername;
  String? _currentRole;

  // STATO PUBBLICO (Getters)
  bool get isAuthenticated => _accessToken != null;
  String? get currentUsername => _currentUsername;
  String? get currentRole => _currentRole;
  String? get accessToken => _accessToken; // Accessibile per l'AuthClient

  AuthService() 
  {
    // Carica i token esistenti all'avvio
    _loadStoredTokens();
  }

  // Metodo helper per le chiamate API PUBBLICHE (usando _publicClient)
  Future<http.Response> _post(String endpoint, Map<String, String> body) async 
  {
    final url = Uri.parse('$_baseUrl/$endpoint');
    return _publicClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
  }

  // --- UTILITY PER JWT ---
  Map<String, dynamic>? _decodeJwt(String token) 
  {
    try 
    {
      final parts = token.split('.');
      if (parts.length != 3) 
      {
        throw const FormatException('Token non valido (non 3 parti)');
      }
      // La payload è la seconda parte (indice 1) e deve essere base64url decodificata
      final payload = parts[1];
      final normalizedPayload = base64Url.decode(base64Url.normalize(payload));
      return json.decode(utf8.decode(normalizedPayload));
    } 
    catch (e) 
    {
      debugPrint('Errore durante la decodifica JWT: $e');
      return null;
    }
  }

  bool _isTokenExpired(String token) 
  {
    final payload = _decodeJwt(token);
    if (payload == null || !payload.containsKey('exp')) 
    {
      return true;
    }

    final expirationDate = DateTime.fromMillisecondsSinceEpoch(
      payload['exp'] * 1000,
    );
    // Margine di sicurezza di 1 minuto
    final isExpired = expirationDate
        .subtract(const Duration(minutes: 1))
        .isBefore(DateTime.now());

    final expirationTimeFormatted = DateFormat(
      'dd/MM/yyyy HH:mm:ss',
    ).format(expirationDate.toLocal());

    debugPrint('Token scade il: $expirationTimeFormatted. Scaduto: $isExpired');

    return isExpired;
  }

  // --- GESTIONE TOKEN LOCALE ---
  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
    required String username,
    required String role,
  }) async 
  {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _roleKey, value: role);

    // Aggiorna lo stato in memoria
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _currentUsername = username;
    _currentRole = role;
    notifyListeners();
  }

  Future<void> _deleteTokens() async 
  {
    // Rimuovi tutti gli elementi correlati
    await _storage.deleteAll();

    // Resetta lo stato in memoria
    _accessToken = null;
    _refreshToken = null;
    _currentUsername = null;
    _currentRole = null;
    notifyListeners();
  }

  // Carica e verifica i token all'avvio dell'app
  Future<void> _loadStoredTokens() async 
  {
    try
    {
      final token = await _storage.read(key: _accessTokenKey);
      final refresh = await _storage.read(key: _refreshTokenKey);
      final username = await _storage.read(key: _usernameKey);
      final role = await _storage.read(key: _roleKey);

      if (token != null &&
          refresh != null &&
          username != null &&
          role != null) 
      {
        _accessToken = token;
        _refreshToken = refresh;
        _currentUsername = username;
        _currentRole = role;

        debugPrint('Token trovato nello storage. Controllo scadenza...');

        if (_isTokenExpired(token)) 
        {
          debugPrint('Access Token scaduto. Tenteremo il refresh...');
          // Se il token è scaduto, usa il Refresh Token per ottenerne uno nuovo
          final success = await refreshAccessToken();
          if (!success) 
          {
            debugPrint('Refresh fallito. Utente deve riloggare.');
            // Il refreshAccessToken fallito chiama già logout()
          }
        } 
        else 
        {
          // Token valido, notifica e continua
          debugPrint('Access Token valido. Autenticazione completata.');
          notifyListeners();
        }
      } 
      else 
      {
        debugPrint(
          'Nessun token valido trovato. Inizializzazione completata (non autenticato).',
        );
        notifyListeners(); // Notifica per mostrare LoginScreen
      }
    } 
    catch (e)
    {
      debugPrint('Errore nel caricamento dei token dallo storage: $e');
      await _deleteTokens();
    }
  }

  // --- REFRESH TOKEN ---
  Future<bool> refreshAccessToken() async 
  {
    if (_refreshToken == null) return false;

    try 
    {
      final response = await _post('refresh', {'refreshToken': _refreshToken!});

      if (response.statusCode == 200) 
      {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));

        // Salva i NUOVI token e i dati utente
        await _saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
          username: authResponse.username,
          role: authResponse.ruolo,
        );
        return true; // Refresh avvenuto con successo
      }
      else 
      {
        // Refresh Token non valido o scaduto -> Logout completo
        await logout();
        return false;
      }
    } 
    catch (e) 
    {
      debugPrint('Errore durante il refresh del token: $e');
      await logout();
      return false;
    }
  }

  // --- LOGIN ---
  Future<String?> login(String usernameOrEmail, String password) async 
  {
    try 
    {
      final response = await _post('login', 
      {
        // I campi corrispondono ai campi di LoginRequest del backend
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      });

      if (response.statusCode == 200) 
      {
        final authResponse = AuthResponse.fromJson(json.decode(response.body));

        // Salva i token nello storage sicuro e aggiorna lo stato
        await _saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
          username: authResponse.username,
          role: authResponse.ruolo,
        );
        return null; // Successo
      } 
      else if (response.statusCode == 401) 
      {
        return "Credenziali non valide. Per favore, riprova.";
      } 
      else 
      {
        final body = json.decode(response.body);
        return body['message'] ??
            "Errore di accesso: Status ${response.statusCode}";
      }
    } 
    catch (e) 
    {
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
  }) async 
  {
    try 
    {
      final response = await _post('register', 
      {
        // I campi corrispondono ai campi di RegistrazioneRequest del backend
        'username': username,
        'email': email,
        'password': password,
        'nome': nome,
        'cognome': cognome,
      });

      if (response.statusCode == 201) 
      {
        return null; // Registrazione avvenuta con successo
      } 
      else if (response.statusCode == 409 || response.statusCode == 400) 
      {
        // Il backend restituisce 409 o 400 per conflitti (username/email già in uso) o validazione non riuscita
        final body = json.decode(response.body);
        return body['message'] ??
            'Errore di registrazione. Username o Email già in uso.';
      } 
      else 
      {
        return "Errore di registrazione: Status ${response.statusCode}";
      }
    } 
    catch (e) 
    {
      return "Errore di connessione al server: $e";
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async 
  {
    final tokenToInvalidate = _refreshToken;

    // 1. Rimuovi i token dallo storage sicuro e resetta lo stato locale immediatamente
    await _deleteTokens();

    // 2. Tenta la chiamata al backend per invalidare il Refresh Token (se esiste)
    if (tokenToInvalidate != null) 
    {
      try 
      {
        // Usa _post (che usa il client pubblico)
        await _post('logout', {'refreshToken': tokenToInvalidate});
      } 
      catch (e) 
      {
        debugPrint(
          'Errore durante il logout sul backend, procedo comunque con la pulizia locale: $e',
        );
      }
    }
  }
}
