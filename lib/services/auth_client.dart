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
    
    // PRIMA RICHIESTA
    final firstResponse = await _sendRequest(request);
    
    // Se non è 401, ritorna direttamente
    if (firstResponse.statusCode != 401) 
    {
      return firstResponse;
    }
    
    // Gestione 401 - Token scaduto
    final refreshSuccess = await _authService.refreshAccessToken();
    
    if (refreshSuccess && _authService.isAuthenticated) 
    {
      final newToken = _authService.accessToken;
      if (newToken != null) 
      {
        // RICREA COMPLETAMENTE LA REQUEST
        return await _sendRequest(request, newToken: newToken);
      }
    }
    
    _authService.logout();
    throw Exception('Sessione scaduta');
  }

  // METODO AUSILIARIO PER INVIARE RICHIESTE
  Future<http.StreamedResponse> _sendRequest(http.BaseRequest request, {String? newToken}) async 
  {
    // Crea una COPIA della request originale
    final newRequest = http.Request(request.method, request.url);
    
    // Copia headers originali (escludendo Authorization se presente)
    newRequest.headers.addAll(request.headers);
    if (newRequest.headers.containsKey('Authorization')) 
    {
      newRequest.headers.remove('Authorization');
    }
    
    // Aggiungi headers di base
    newRequest.headers['Content-Type'] = 'application/json';
    newRequest.headers['Accept'] = 'application/json';
    
    // Aggiungi il token (nuovo o originale)
    final token = newToken ?? _authService.accessToken;
    if (token != null && !_isPublicEndpoint(request.url.path)) 
    {
      newRequest.headers['Authorization'] = 'Bearer $token';
    }
    
    // Copia il body se presente
    if (request is http.Request) 
    {
      newRequest.body = (request).body;
    }
    
    // Invia la NUOVA richiesta
    final response = await _inner.send(newRequest);
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