import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'auth_service.dart';

// Definiamo un typedef per la funzione di refresh del token.
typedef TokenRefresher = Future<bool> Function();

// AuthClient si estende da BaseClient per avvolgere il client HTTP standard.
class AuthClient extends BaseClient 
{
  final http.Client _inner;
  final TokenRefresher _refresher;
  final AuthService _authService;

  // Rotte pubbliche (o rotte di autenticazione) che NON DEVONO avere l'header Authorization
  // Queste rotte sono gestite direttamente nel AuthService
  static const List<String> _publicEndpoints = [
    '/api/auth/login',
    '/api/auth/register',
    '/api/auth/refresh',
    '/api/auth/logout',
  ];

  AuthClient(this._inner, this._refresher, this._authService);

  @override
  Future<StreamedResponse> send(BaseRequest request) async 
  {
    // Aggiungi il token alla richiesta, se necessario
    if (!_isPublic(request.url.path) && _authService.accessToken != null) 
    {
      request.headers['Authorization'] = 'Bearer ${_authService.accessToken}';
      request.headers['Accept'] = 'application/json';
    }

    // Invia la richiesta originale
    http.StreamedResponse response = await _inner.send(request);

    // Intercetta gli errori 401 (Unauthorized)
    if (response.statusCode == 401) 
    {
      // Chiude il flusso di dati della risposta 401 corrente
      response.stream.listen((_) {}).cancel(); 

      // Tenta il Refresh del Token
      final refreshSuccess = await _refresher();

      if (refreshSuccess) 
      {
        // Se il refresh ha successo:
        // Cloniamo la richiesta originale (inclusi corpo, headers, metodo)
        final newRequest = _cloneRequest(request);
        
        // Aggiungiamo il NUOVO token alla richiesta clonata
        newRequest.headers['Authorization'] = 'Bearer ${_authService.accessToken!}';

        // Ripetiamo la richiesta originale
        return _inner.send(newRequest);
      } 
      // Se il refresh fallisce, restituiamo la risposta 401 originale
    }

    return response;
  }

  // Helper per controllare se l'endpoint è pubblico (e quindi non aggiungere il token)
  bool _isPublic(String path) 
  {
    return _publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  // Helper per clonare la richiesta
  BaseRequest _cloneRequest(BaseRequest original) 
  {
    final cloned = http.Request(original.method, original.url)
      ..headers.addAll(original.headers)
      ..followRedirects = original.followRedirects
      ..maxRedirects = original.maxRedirects
      ..persistentConnection = original.persistentConnection;
    
    // Gestione del corpo della richiesta per POST/PUT/PATCH
    if (original is http.Request) 
    {
      cloned.bodyBytes = original.bodyBytes;
    } 
    else if (original is http.MultipartRequest) 
    {
      cloned as http.MultipartRequest
        ..fields.addAll(original.fields)
        ..files.addAll(original.files);
    }
    return cloned;
  }
}