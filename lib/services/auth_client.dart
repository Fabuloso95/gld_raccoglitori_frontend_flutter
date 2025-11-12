import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AuthClient extends http.BaseClient 
{
  final http.Client _inner;
  final AuthService _authService;

  AuthClient(this._inner, this._authService);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async 
  {
    // DEBUG: Verifica stato autenticazione
    print('🔐 AuthClient - Stato autenticazione: ${_authService.isAuthenticated}');
    print('🔐 AuthClient - Token: ${_authService.accessToken}');
    print('🔐 AuthClient - Endpoint: ${request.url.path}');
    
    // CORREZIONE: Aggiungi SEMPRE il token se l'utente è autenticato
    // (tranne per i veri endpoint pubblici come login/register)
    if (_authService.isAuthenticated && !_isPublicEndpoint(request.url.path)) 
    {
      final token = _authService.accessToken;
      if (token != null) 
      {
        request.headers['Authorization'] = 'Bearer $token';
        print('🔐 AuthClient - Token aggiunto alla richiesta');
      }
    }
    else if (_authService.isAuthenticated) 
    {
      print('🔐 AuthClient - Endpoint pubblico, token non aggiunto');
    }
    else 
    {
      print('🔐 AuthClient - Utente non autenticato');
    }
    
    // Aggiungi headers comuni
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'application/json';

    print('🔐 AuthClient - Headers finali: ${request.headers}');

    final response = await _inner.send(request);

    // DEBUG: Verifica risposta
    print('🔐 AuthClient - Response status: ${response.statusCode}');
    
    // Gestione errori di autenticazione
    if (response.statusCode == 401) 
    {
      print('🔐 AuthClient - Token scaduto, tentativo refresh...');
      final refreshSuccess = await _authService.refreshAccessToken();
      if (refreshSuccess && _authService.isAuthenticated) 
      {
        print('🔐 AuthClient - Refresh riuscito, ripeto richiesta');
        final newToken = _authService.accessToken;
        if (newToken != null) 
        {
          request.headers['Authorization'] = 'Bearer $newToken';
          return await _inner.send(request);
        }
      }
      else 
      {
        print('🔐 AuthClient - Refresh fallito, logout forzato');
        _authService.logout();
        throw Exception('Sessione scaduta');
      }
    }

    return response;
  }

  bool _isPublicEndpoint(String path) 
  {
    final publicEndpoints = 
    [
      '/api/auth/login',
      '/api/auth/register',
      '/api/auth/refresh',
    ];
    // Solo questi endpoint NON devono avere il token
    return publicEndpoints.any((endpoint) => path.endsWith(endpoint));
  }
}