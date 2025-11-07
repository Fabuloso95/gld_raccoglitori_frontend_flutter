import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../repository/auth_repository.dart';

class AuthService with ChangeNotifier 
{
  final AuthRepository _authRepository;
  final FlutterSecureStorage _storage;

  // Chiavi per storage
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _usernameKey = 'username';
  static const String _roleKey = 'role';

  // Stato
  String? _accessToken;
  String? _refreshToken;
  String? _currentUsername;
  String? _currentRole;

  AuthService({
    AuthRepository? authRepository,
    FlutterSecureStorage? storage,
  })  : _authRepository = authRepository ?? AuthRepository(),
        _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        )
        {
    _loadStoredTokens();
  }

  // --- GETTERS ---
  bool get isAuthenticated => _accessToken != null;
  String? get currentUsername => _currentUsername;
  String? get currentRole => _currentRole;
  String? get accessToken => _accessToken;
  
  int? get currentUserId 
  {
    if (_accessToken != null) 
    {
      return _authRepository.getUserIdFromToken(_accessToken!);
    }
    return null;
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

    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _currentUsername = username;
    _currentRole = role;
    notifyListeners();
  }

  Future<void> _deleteTokens() async 
  {
    await _storage.deleteAll();
    _accessToken = null;
    _refreshToken = null;
    _currentUsername = null;
    _currentRole = null;
    notifyListeners();
  }

  Future<void> _loadStoredTokens() async 
  {
    try 
    {
      final token = await _storage.read(key: _accessTokenKey);
      final refresh = await _storage.read(key: _refreshTokenKey);
      final username = await _storage.read(key: _usernameKey);
      final role = await _storage.read(key: _roleKey);

      if (token != null && refresh != null && username != null && role != null) 
      {
        _accessToken = token;
        _refreshToken = refresh;
        _currentUsername = username;
        _currentRole = role;

        if (_authRepository.isTokenExpired(token)) 
        {
          await refreshAccessToken();
        } 
        else 
        {
          notifyListeners();
        }
      }
      else 
      {
        notifyListeners();
      }
    } 
    catch (e) 
    {
      debugPrint('Errore caricamento token: $e');
      await _deleteTokens();
    }
  }

  // --- OPERAZIONI AUTH ---
  Future<String?> login(String usernameOrEmail, String password) async 
  {
    try 
    {
      final response = await _authRepository.login(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );

      if (response.statusCode == 200) 
      {
        final data = json.decode(response.body);
        await _saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          username: data['username'],
          role: data['ruolo'],
        );
        return null;
      } 
      else if (response.statusCode == 401) 
      {
        return "Credenziali non valide";
      } 
      else 
      {
        final body = json.decode(response.body);
        return body['message'] ?? "Errore di accesso: ${response.statusCode}";
      }
    } 
    catch (e) 
    {
      return "Errore di connessione: $e";
    }
  }

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
      final response = await _authRepository.register(
        username: username,
        email: email,
        password: password,
        nome: nome,
        cognome: cognome,
      );

      if (response.statusCode == 201) 
      {
        return null;
      } 
      else if (response.statusCode == 409 || response.statusCode == 400) 
      {
        final body = json.decode(response.body);
        return body['message'] ?? 'Username o Email già in uso';
      } 
      else 
      {
        return "Errore registrazione: ${response.statusCode}";
      }
    } 
    catch (e) 
    {
      return "Errore di connessione: $e";
    }
  }

  Future<bool> refreshAccessToken() async 
  {
    if (_refreshToken == null) return false;

    try 
    {
      final response = await _authRepository.refreshToken(_refreshToken!);

      if (response.statusCode == 200) 
      {
        final data = json.decode(response.body);
        await _saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          username: data['username'],
          role: data['ruolo'],
        );
        return true;
      } 
      else 
      {
        await logout();
        return false;
      }
    } 
    catch (e) 
    {
      await logout();
      return false;
    }
  }

  Future<void> logout() async 
  {
    final tokenToInvalidate = _refreshToken;
    await _deleteTokens();

    if (tokenToInvalidate != null) 
    {
      try 
      {
        await _authRepository.logout(tokenToInvalidate);
      } 
      catch (e) 
      {
        debugPrint('Errore logout backend: $e');
      }
    }
  }

  @override
  void dispose() 
  {
    super.dispose();
    _authRepository.dispose();
  }
}