import 'package:flutter/foundation.dart';
import 'package:gld_raccoglitori/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier 
{
  final AuthService _authService;

  // Stato dell'applicazione
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  // Costruttore
  AuthViewModel(this._authService);

  // Getter per lo stato
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  
  // Getter delegati ad AuthService
  bool get isAuthenticated => _authService.isAuthenticated;
  String? get currentUsername => _authService.currentUsername;
  String? get currentRole => _authService.currentRole;
  int? get currentUserId => _authService.currentUserId;

  // Metodi per gestire lo stato di caricamento ed errori
  void _setLoading(bool loading) 
  {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) 
  {
    _error = error;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String? message) 
  {
    _successMessage = message;
    _error = null;
    notifyListeners();
  }

  // Login
  Future<bool> login(String usernameOrEmail, String password) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final errorMessage = await _authService.login(usernameOrEmail, password);
      
      if (errorMessage == null) 
      {
        _setSuccess('Accesso effettuato con successo!');
        return true;
      } 
      else 
      {
        _setError(errorMessage);
        return false;
      }
    } 
    catch (e) 
    {
      _setError('Errore di connessione: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Registrazione
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String nome,
    required String cognome,
  }) async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      final errorMessage = await _authService.register(
        username: username,
        email: email,
        password: password,
        nome: nome,
        cognome: cognome,
      );
      
      if (errorMessage == null) 
      {
        _setSuccess('Registrazione avvenuta con successo! Accedi ora.');
        return true;
      } 
      else 
      {
        _setError(errorMessage);
        return false;
      }
    }
    catch (e) 
    {
      _setError('Errore di connessione: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async 
  {
    _setLoading(true);
    _setError(null);
    
    try 
    {
      await _authService.logout();
      _setSuccess('Logout effettuato con successo');
    } 
    catch (e) 
    {
      _setError('Errore durante il logout: $e');
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  // Refresh token
  Future<bool> refreshToken() async 
  {
    _setLoading(true);
    
    try 
    {
      final success = await _authService.refreshAccessToken();
      return success;
    } 
    catch (e) 
    {
      _setError('Errore nel refresh del token: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  Future<void> loginWithGoogle() async 
  {
    try 
    {
      _setLoading(true);
      _setError(null);

      // Implementa la logica per OAuth2 con Google
      // Questo dipende da come hai configurato l'autenticazione OAuth2
      // Potresti usare un package come url_launcher o webview
      
      // Esempio base:
      final String redirectUrl = 'http://localhost:8080/oauth2/authorization/google';
      
      // Apri il browser o WebView per l'autenticazione OAuth2
      // await launchUrl(Uri.parse(redirectUrl));
      
      // Dovrai gestire il callback con il token

      _setError('Login con Google in sviluppo - URL: $redirectUrl');
    } 
    catch (e) 
    {
      _setError('Errore durante il login con Google: ${e.toString()}');
    }
    finally 
    {
      _setLoading(false);
    }
  }

  // Pulisci gli errori
  void clearError() 
  {
    _setError(null);
  }

  // Pulisci i messaggi di successo
  void clearSuccess() 
  {
    _setSuccess(null);
  }

  // Reset dello stato
  void resetState() 
  {
    _setError(null);
    _setSuccess(null);
    _setLoading(false);
  }

  // Verifica se l'utente è admin
  bool get isAdmin 
  {
    return currentRole?.toUpperCase() == 'ADMIN';
  }

  // Verifica se l'utente può accedere a funzionalità specifiche
  bool canAccess(String feature) 
  {
    switch (feature) {
      case 'admin_panel':
        return isAdmin;
      case 'user_management':
        return isAdmin;
      case 'content_creation':
        return isAuthenticated;
      case 'commenting':
        return isAuthenticated;
      default:
        return isAuthenticated;
    }
  }
}