import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'auth_client.dart';

class HttpClientFactory 
{
  static http.Client createClient(AuthService authService) 
  {
    return AuthClient(http.Client(), authService);
  }
}