import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/lettura_corrente_api_service.dart';
import '../services/proposta_voto_api_service.dart';
import '../services/voto_utente_api_service.dart';
import '../models/lettura_corrente_response.dart';
import '../models/proposta_voto_response.dart';
import '../models/voto_utente_response.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<PropostaVotoResponse?> _libroVincitoreFuture;
  late Future<LetturaCorrenteResponse?> _letturaCorrenteFuture;
  late Future<List<PropostaVotoResponse>> _proposteAttiveFuture;
  late Future<List<VotoUtenteResponse>> _mioVotoFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    final propostaService = Provider.of<PropostaVotoApiService>(context, listen: false);
    final letturaService = Provider.of<LetturaCorrenteApiService>(context, listen: false);
    final votoService = Provider.of<VotoUtenteApiService>(context, listen: false);
    
    final meseCorrente = _getMeseCorrente();
    
    // ✅ API REALI - come nel tuo backend
    _libroVincitoreFuture = propostaService.getWinnerProposta(meseCorrente);
    _letturaCorrenteFuture = _getLetturaCorrente(letturaService);
    _proposteAttiveFuture = propostaService.getProposteByMese(meseVotazione: meseCorrente);
    _mioVotoFuture = votoService.checkExistingVote(meseVotazione: meseCorrente);
  }

  String _getMeseCorrente() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<LetturaCorrenteResponse?> _getLetturaCorrente(LetturaCorrenteApiService service) async {
  try {
    final letture = await service.getMyReadings();
    
    if (letture.isEmpty) {
      return null; 
    }

    try {
      final letturaNonCompletata = letture.firstWhere(
        (lettura) => lettura.dataCompletamento == null,
      );
      return letturaNonCompletata; 
    } 
    catch (e) 
    {
      return letture.last;
    }
    
  } catch (e) {
    print('Errore caricamento lettura corrente: $e');
    return null;
  }
}

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard GDL'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.logout(),
            tooltip: 'Logout',
          ),
        ],
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Lettura',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_vote),
            label: 'Votazioni',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Discussioni',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/lettura');
              break;
            case 2:
              Navigator.pushNamed(context, '/votazioni');
              break;
            case 3:
              Navigator.pushNamed(context, '/discussioni');
              break;
            case 4:
              Navigator.pushNamed(context, '/profilo');
              break;
          }
        },
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadDashboardData();
          });
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ BENVENUTO UTENTE
              _buildUserWelcome(authService),
              const SizedBox(height: 24),
              
              // ✅ LIBRO VINCITORE DEL MESE
              _buildLibroVincitoreSection(),
              const SizedBox(height: 24),
              
              // ✅ PROGRESSO LETTURA CORRENTE
              _buildProgressoLetturaSection(),
              const SizedBox(height: 24),
              
              // ✅ PROPOSTE VOTO ATTIVE
              _buildProposteVotoSection(),
              const SizedBox(height: 24),
              
              // ✅ STATO MIO VOTO
              _buildMioVotoSection(),
              const SizedBox(height: 24),
              
              // ✅ PROSSIMI EVENTI (placeholder per ora)
              _buildProssimiEventiSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserWelcome(AuthService authService) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFF1E88E5),
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Benvenuto, ${authService.currentUsername}!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ruolo: ${authService.currentRole ?? 'USER'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibroVincitoreSection() {
    return FutureBuilder<PropostaVotoResponse?>(
      future: _libroVincitoreFuture,
      builder: (context, snapshot) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'Libro Vincitore del Mese',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator()),
                
                if (snapshot.hasError)
                  _buildErrorWidget('Errore nel caricamento del vincitore'),
                
                if (snapshot.hasData && snapshot.data != null)
                  _buildLibroVincitoreCard(snapshot.data!),
                
                if (snapshot.hasData && snapshot.data == null)
                  _buildNessunVincitoreWidget(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLibroVincitoreCard(PropostaVotoResponse propostaVincitrice) {
    final libro = propostaVincitrice.libroProposto;
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/book-details',
          arguments: {'bookId': libro.id},
        );
      },
      child: Row(
        children: [
          // Copertina libro
          Container(
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: libro.copertinaUrl.isNotEmpty
                ? Image.network(libro.copertinaUrl, fit: BoxFit.cover)
                : const Icon(Icons.emoji_events, size: 30, color: Colors.amber),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  libro.titolo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'di ${libro.autore}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.how_to_vote, size: 14, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(
                      '${propostaVincitrice.numVoti} voti',
                      style: TextStyle(color: Colors.green[700], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildNessunVincitoreWidget() {
    return const Column(
      children: [
        Icon(Icons.emoji_events_outlined, size: 40, color: Colors.grey),
        SizedBox(height: 8),
        Text(
          'Nessun vincitore per questo mese',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressoLetturaSection() {
    return FutureBuilder<LetturaCorrenteResponse?>(
      future: _letturaCorrenteFuture,
      builder: (context, snapshot) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.timeline, color: Color(0xFF1E88E5)),
                    SizedBox(width: 8),
                    Text(
                      'La Tua Lettura Corrente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator()),
                
                if (snapshot.hasError)
                  _buildErrorWidget('Errore nel caricamento della lettura'),
                
                if (snapshot.hasData && snapshot.data != null)
                  _buildProgressoCard(snapshot.data!),
                
                if (snapshot.hasData && snapshot.data == null)
                  _buildNessunaLetturaCard(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressoCard(LetturaCorrenteResponse lettura) {
    // Calcola percentuale di completamento
    final progressoPercent = (lettura.paginaCorrente / 100) * 100; // TODO: Sostituisci con numeroPagine reale
    
    return Column(
      children: [
        LinearProgressIndicator(
          value: progressoPercent / 100,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pagina ${lettura.paginaCorrente}'),
            Text('${progressoPercent.toStringAsFixed(1)}% completato'),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/lettura');
          },
          child: const Text('Continua a Leggere'),
        ),
      ],
    );
  }

  Widget _buildNessunaLetturaCard() {
    return Column(
      children: [
        const Icon(Icons.menu_book_outlined, size: 40, color: Colors.grey),
        const SizedBox(height: 8),
        const Text(
          'Non stai leggendo nessun libro',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/library');
          },
          child: const Text('Scegli un Libro'),
        ),
      ],
    );
  }

  Widget _buildProposteVotoSection() {
    return FutureBuilder<List<PropostaVotoResponse>>(
      future: _proposteAttiveFuture,
      builder: (context, snapshot) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.how_to_vote, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Votazione del Mese',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator()),
                
                if (snapshot.hasError)
                  _buildErrorWidget('Errore nel caricamento delle proposte'),
                
                if (snapshot.hasData && snapshot.data!.isNotEmpty)
                  ...snapshot.data!.take(4).map((proposta) => 
                    _buildPropostaVotoItem(proposta)
                  ),
                
                if (snapshot.hasData && snapshot.data!.isEmpty)
                  _buildNessunaPropostaWidget(),
                
                const SizedBox(height: 12),
                if (snapshot.hasData && snapshot.data!.isNotEmpty)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/votazioni');
                      },
                      child: const Text('Vedi Tutte le Proposte e Vota'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPropostaVotoItem(PropostaVotoResponse proposta) {
    final libro = proposta.libroProposto;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
        child: libro.copertinaUrl.isNotEmpty
            ? Image.network(libro.copertinaUrl, fit: BoxFit.cover)
            : const Icon(Icons.book, size: 20, color: Colors.grey),
      ),
      title: Text(libro.titolo),
      subtitle: Text('di ${libro.autore} • ${proposta.numVoti} voti'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/book-details',
          arguments: {'bookId': libro.id},
        );
      },
    );
  }

  Widget _buildNessunaPropostaWidget() {
    return const Column(
      children: [
        Icon(Icons.how_to_vote_outlined, size: 40, color: Colors.grey),
        SizedBox(height: 8),
        Text(
          'Nessuna votazione attiva',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildMioVotoSection() {
    return FutureBuilder<List<VotoUtenteResponse>>(
      future: _mioVotoFuture,
      builder: (context, snapshot) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Il Tuo Voto',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator()),
                
                if (snapshot.hasError)
                  _buildErrorWidget('Errore nel caricamento del tuo voto'),
                
                if (snapshot.hasData && snapshot.data!.isNotEmpty)
                  _buildMioVotoCard(snapshot.data!),
                
                if (snapshot.hasData && snapshot.data!.isEmpty)
                  _buildNessunVotoWidget(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMioVotoCard(List<VotoUtenteResponse> voti) {
  final voto = voti.first;
  final numVoti = voti.length;
  
  return Column(
    children: [
      const Icon(Icons.check_circle, size: 40, color: Colors.green),
      const SizedBox(height: 8),
      const Text(
        'Hai già votato!',
        style: TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Hai espresso $numVoti voto${numVoti > 1 ? 'i' : ''} questo mese',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[100]!),
        ),
        child: Column(
          children: [
            Text(
              'Mese di votazione:',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              voto.meseVotazione,
              style: TextStyle(
                color: Colors.green[800],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

  Widget _buildNessunVotoWidget() {
    return Column(
      children: [
        const Icon(Icons.pending_actions, size: 40, color: Colors.orange),
        const SizedBox(height: 8),
        const Text(
          'Non hai ancora votato',
          style: TextStyle(color: Colors.orange),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/votazioni');
          },
          child: const Text('Vota Ora'),
        ),
      ],
    );
  }

  Widget _buildProssimiEventiSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.event, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Prossimi Eventi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const ListTile(
              leading: Icon(Icons.video_call, color: Colors.green),
              title: Text('Chiamata Discussione Libro'),
              subtitle: Text('15 Gennaio 2024 - 18:00'),
            ),
            const ListTile(
              leading: Icon(Icons.how_to_vote, color: Colors.orange),
              title: Text('Scadenza Votazione'),
              subtitle: Text('20 Gennaio 2024 - 23:59'),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/calendario');
                },
                child: const Text('Vedi Calendario Completo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Column(
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 40),
        const SizedBox(height: 8),
        Text(
          message,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}