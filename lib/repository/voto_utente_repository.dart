import 'package:http/http.dart' as http;

class VotoUtenteRepository 
{
  final http.Client client;
  final String baseUrl;

  VotoUtenteRepository({
    required this.baseUrl,
    required http.Client client,
  }) : client = client;

  Future<http.Response> findById(int id) async 
  {
    final url = Uri.parse('$baseUrl/api/voti/$id');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> checkExistingVote(String meseVotazione) async 
  {
    final url = Uri.parse('$baseUrl/api/voti/check/mese/$meseVotazione');
    
    return client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  void dispose() 
  {
    client.close();
  }
}