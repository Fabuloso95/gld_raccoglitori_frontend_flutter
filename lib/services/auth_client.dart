// services/auth_client.dart
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'auth_service.dart';

class AuthClient extends BaseClient 
{
  final http.Client _inner;
  final AuthService _authService;

  static const List<String> _publicEndpoints = [
    '/api/auth/login',
    '/api/auth/register',
    '/api/auth/refresh',
    '/api/auth/logout',
  ];

  AuthClient(this._inner, this._authService);

  @override
  Future<StreamedResponse> send(BaseRequest request) async 
  {
    // ✅ Aggiungi il token se necessario
    if (!_isPublic(request.url.path) && _authService.accessToken != null) 
    {
      request.headers['Authorization'] = 'Bearer ${_authService.accessToken}';
      request.headers['Accept'] = 'application/json';
    }

    final response = await _inner.send(request);

    // ✅ Intercetta errori 401
    if (response.statusCode == 401) 
    {
      response.stream.listen((_) {}).cancel();
      
      // ✅ Usa il metodo refreshAccessToken dell'AuthService
      final refreshSuccess = await _authService.refreshAccessToken();
      
      if (refreshSuccess && _authService.accessToken != null) 
      {
        final newRequest = _cloneRequest(request);
        newRequest.headers['Authorization'] = 'Bearer ${_authService.accessToken!}';
        return _inner.send(newRequest);
      }
    }

    return response;
  }

  bool _isPublic(String path) 
  {
    return _publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  BaseRequest _cloneRequest(BaseRequest original) 
  {
    final cloned = http.Request(original.method, original.url)
      ..headers.addAll(original.headers)
      ..followRedirects = original.followRedirects
      ..maxRedirects = original.maxRedirects
      ..persistentConnection = original.persistentConnection;
    
    if (original is http.Request) 
    {
      cloned.bodyBytes = original.bodyBytes;
    }
    
    return cloned;
  }
}