import 'package:flutter/material.dart';
import 'package:gld_raccoglitori/repository/evento_repository.dart';
import 'package:gld_raccoglitori/screens/impostazioni_screen.dart';
import 'package:provider/provider.dart';
import 'screens/calendario_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/crea_libro_screen.dart';
import 'screens/crea_utente_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/dettaglio_libro_screen.dart';
import 'screens/lettura_screen.dart';
import 'screens/lista_chat_screen.dart';
import 'screens/lista_commenti_screen.dart';
import 'screens/lista_curiosita_screen.dart';
import 'screens/lista_frasi_preferite_screen.dart';
import 'screens/lista_libri_screen.dart';
import 'screens/lista_raccoglitori_screen.dart';
import 'screens/lista_utenti_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/votazioni_screen.dart';
import 'services/auth_service.dart';
import 'services/commenti_api_service.dart';
import 'services/curiosita_api_service.dart';
import 'services/evento_service.dart';
import 'services/frase_preferita_api_service.dart';
import 'services/lettura_corrente_api_service.dart';
import 'services/libro_api_service.dart';
import 'services/messaggio_chat_api_service.dart';
import 'services/proposta_voto_api_service.dart';
import 'services/raccoglitori_api_service.dart';
import 'services/utente_api_service.dart';
import 'services/voto_utente_api_service.dart';
import 'view_models/auth_view_model.dart';
import 'view_models/chat_view_model.dart';
import 'view_models/commenti_view_model.dart';
import 'view_models/curiosita_view_model.dart';
import 'view_models/evento_view_model.dart';
import 'view_models/frase_preferita_view_model.dart';
import 'view_models/lettura_corrente_view_model.dart';
import 'view_models/libro_view_model.dart';
import 'view_models/proposta_voto_view_model.dart';
import 'view_models/raccoglitori_view_model.dart';
import 'view_models/utente_view_model.dart';
import 'view_models/voto_utente_view_model.dart';
import 'services/impostazioni_api_service.dart';
import 'view_models/impostazioni_view_model.dart';

void main() 
{
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) {
            final authService = context.read<AuthService>();
            return AuthViewModel(authService);
          },
        ),
        Provider<RaccoglitoriApiService>(
          create: (context) {
            final authService = context.read<AuthService>();
            return RaccoglitoriApiService(authService);
          },
        ),
        Provider<CommentiApiService>(
          create: (context) {
            final authService = context.read<AuthService>();
            return CommentiApiService(
              authService: authService,
              baseUrl: "http://localhost:8080",
            );
          },
        ),
        Provider<CuriositaApiService>(
          create: (context) {
            final authService = context.read<AuthService>();
            return CuriositaApiService(
              authService: authService,
              baseUrl: "http://localhost:8080",
            );
          },
        ),
        Provider<FrasePreferitaApiService>(
          create: (context) {
            final authService = context.read<AuthService>();
            return FrasePreferitaApiService(
              authService: authService,
              baseUrl: "http://localhost:8080",
            );
          },
        ),
        Provider<LetturaCorrenteApiService>(
          create: (context) {
            final authService = context.read<AuthService>();
            return LetturaCorrenteApiService(
              authService: authService,
              baseUrl: "http://localhost:8080",
            );
          },
        ),
        Provider<LibroApiService>(
          create: (context) {
            final authService = context.read<AuthService>();
            return LibroApiService(
              authService: authService,
              baseUrl: "http://localhost:8080",
            );
          },
        ),
        Provider<MessaggioChatApiService>(
          create: (context) {
            final authService = context.read<AuthService>();
            return MessaggioChatApiService(
              authService: authService,
              baseUrl: "http://localhost:8080",
            );
          },
        ),
        Provider<PropostaVotoApiService>(
          create: (context) {
            final authService = context.read<AuthService>();
            return PropostaVotoApiService(
              authService: authService,
              baseUrl: "http://localhost:8080",
            );
          },
        ),
        Provider<UtenteApiService>(
          create: (context) {
            final authService = context.read<AuthService>();
            return UtenteApiService(
              authService: authService,
              baseUrl: "http://localhost:8080",
            );
          },
        ),
        Provider<VotoUtenteApiService>(
          create: (context) {
            final authService = context.read<AuthService>();
            return VotoUtenteApiService(
              authService: authService,
              baseUrl: "http://localhost:8080",
            );
          },
        ),
        Provider<ImpostazioniApiService>(
          create: (context) {
            final authService = context.read<AuthService>();
            return ImpostazioniApiService(
              authService: authService,
              baseUrl: "http://localhost:8080",
            );
          },
        ),
        Provider<EventoRepository>(
          create: (context) {
            final authService = context.read<AuthService>();
            return EventoRepository(
              baseUrl: "http://localhost:8080",
              token: authService.accessToken,
            );
          },
        ),
        Provider<EventoService>(
          create: (context) {
            final eventoRepository = context.read<EventoRepository>();
            return EventoService(repository: eventoRepository);
          },
        ),
        ChangeNotifierProvider<UtenteViewModel>(
          create: (context) {
            final utenteService = context.read<UtenteApiService>();
            return UtenteViewModel(utenteService);
          },
        ),
        ChangeNotifierProvider<ChatViewModel>(
          create: (context) {
            final chatService = context.read<MessaggioChatApiService>();
            return ChatViewModel(chatService);
          },
        ),
        ChangeNotifierProvider<CommentiViewModel>(
          create: (context) {
            final commentiService = context.read<CommentiApiService>();
            return CommentiViewModel(commentiService);
          },
        ),
        ChangeNotifierProvider<CuriositaViewModel>(
          create: (context) {
            final curiositaService = context.read<CuriositaApiService>();
            return CuriositaViewModel(curiositaService);
          },
        ),
        ChangeNotifierProvider<FrasePreferitaViewModel>(
          create: (context) {
            final frasePreferitaService = context.read<FrasePreferitaApiService>();
            return FrasePreferitaViewModel(frasePreferitaService);
          },
        ),
        ChangeNotifierProvider<LetturaCorrenteViewModel>(
          create: (context) {
            final letturaService = context.read<LetturaCorrenteApiService>();
            return LetturaCorrenteViewModel(letturaService);
          },
        ),
        ChangeNotifierProvider<LibroViewModel>(
          create: (context) {
            final libroService = context.read<LibroApiService>();
            return LibroViewModel(libroService);
          },
        ),
        ChangeNotifierProvider<VotoUtenteViewModel>(
          create: (context) {
            final votoUtenteService = context.read<VotoUtenteApiService>();
            final authService = context.read<AuthService>();
            return VotoUtenteViewModel(votoUtenteService, authService);
          },
        ),
        ChangeNotifierProvider<PropostaVotoViewModel>(
          create: (context) {
            final propostaService = context.read<PropostaVotoApiService>();
            final votoUtenteVM = context.read<VotoUtenteViewModel>();
            return PropostaVotoViewModel(propostaService, votoUtenteVM);
          },
        ),
        ChangeNotifierProvider<RaccoglitoriViewModel>(
          create: (context) {
            final raccoglitoriService = context.read<RaccoglitoriApiService>();
            return RaccoglitoriViewModel(raccoglitoriService);
          },
        ),
        ChangeNotifierProvider<ImpostazioniViewModel>(
          create: (context) {
            final impostazioniService = context.read<ImpostazioniApiService>();
            return ImpostazioniViewModel(impostazioniService);
          },
        ),
        ChangeNotifierProvider<EventoViewModel>(
          create: (context) {
            final eventoService = context.read<EventoService>();
            return EventoViewModel(eventoService: eventoService);
          },
        ),
      ],
      child: const GDLApp(),
    ),
  );
}

class GDLApp extends StatelessWidget 
{
  const GDLApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return Consumer<ImpostazioniViewModel>(
      builder: (context, impostazioniVM, child) 
      {
        final tema = impostazioniVM.impostazioni?.tema ?? 'system';
        
        switch (tema) {
          case 'dark':
            break;
          case 'light':
            break;
          default: // system
        }
      return MaterialApp(
        title: 'GDL Raccoglitori',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          useMaterial3: true,
        ),
        
        // ✅ ROUTING CONFIGURATION (simile a Angular RouterModule)
        initialRoute: '/', // Route iniziale
        routes: {
          '/': (context) => const AuthWrapper(),
          '/dashboard': (context) => const DashboardScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
          '/home': (context) => const HomeScreen(),
          '/utenti': (context) => const ListaUtentiScreen(),
          '/chat': (context) => const ListaChatScreen(),
          '/libri': (context) => const ListaLibriScreen(),
          '/crea-libro': (context) => const CreaLibroScreen(),
          '/dettaglio-libro': (context) 
          {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return DettaglioLibroScreen(libroId: args['libroId']);
          },
          '/votazioni': (context) => const VotazioniScreen(),
          '/raccoglitori': (context) => const ListaRaccoglitoriScreen(),
          '/discussioni': (context) => const ListaChatScreen(),
          '/profilo': (context) => const ProfileScreen(),
          '/calendario': (context) => const CalendarioScreen(),
          '/impostazioni': (context) => const ImpostazioniScreen()
        },
        
        // ✅ LAZY LOADING (simile a loadChildren in Angular)
        onGenerateRoute: (settings) {
          // Puoi caricare screen on-demand per performance
          switch (settings.name) 
          {
            case '/crea-utente':
              return MaterialPageRoute(builder: (_) => const CreaUtenteScreen());
            case '/dettaglio-utente':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => DettaglioUtenteScreen(utenteId: args['utenteId']),
              );
            case '/chat-screen':
              final args = settings.arguments as Map<String, dynamic>;
              final authService = Provider.of<AuthService>(context, listen: false);
              final utenteCorrenteId = authService.currentUserId;
              
              if (utenteCorrenteId == null) 
              {
                return MaterialPageRoute(builder: (_) => const LoginScreen());
              }
              
              return MaterialPageRoute(
                builder: (_) => ChatScreen(
                  gruppoId: args['gruppoId'],
                  altroUtenteId: args['altroUtenteId'],
                  tipoChat: args['tipoChat'],
                  utenteCorrenteId: utenteCorrenteId,
                ),
              );
            case '/commenti':
              final args = settings.arguments as Map<String, dynamic>;
              final authService = Provider.of<AuthService>(context, listen: false);
              final utenteCorrenteId = authService.currentUserId ?? args['utenteCorrenteId'];
              return MaterialPageRoute(
                builder: (_) => ListaCommentiScreen(
                  letturaCorrenteId: args['letturaCorrenteId'],
                  paginaRiferimento: args['paginaRiferimento'],
                  titoloLettura: args['titoloLettura'],
                  utenteCorrenteId: utenteCorrenteId!,
                ),
              );
            case '/curiosita':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => ListaCuriositaScreen(
                  libroId: args['libroId'],
                  paginaRiferimento: args['paginaRiferimento'],
                  titoloLibro: args['titoloLibro'],
                ),
              );
            case '/frasi-preferite':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => ListaFrasiPreferiteScreen(
                  libroId: args['libroId'],
                  titoloLibro: args['titoloLibro'],
                ),
              );
            case '/lettura':
              final args = settings.arguments as Map<String, dynamic>? ?? {};
              
              // DEBUG: Verifica i parametri
              print('🔍 DEBUG Routing Lettura - args: $args');
              
              // Usa parametri coerenti - preferibilmente libroId invece di bookId
              final libroId = args['libroId'] ?? args['bookId'];
              final bookTitle = args['bookTitle'] ?? args['titoloLibro'] ?? '';
              final numeroPagineTotali = args['numeroPagineTotali'] ?? args['totalPages'] ?? 0;
              
              if (libroId == null) {
                print('❌ ERRORE Routing Lettura - libroId mancante');
                // Fallback a una schermata di errore o home
                return MaterialPageRoute(builder: (_) => const HomeScreen());
              }
              
              return MaterialPageRoute(
                builder: (_) => LetturaScreen(
                  bookId: libroId,
                  bookTitle: bookTitle,
                  numeroPagineTotali: numeroPagineTotali,
                ),
              );
            case '/libri-da-leggere':
              return MaterialPageRoute(
                builder: (_) => const ListaLibriScreen(mostraSoloNonLetti: true),
              );
            case '/dettaglio-libro':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => DettaglioLibroScreen(libroId: args['libroId']),
              );
          }
          return null;
        },
      );
  });
  }
}

// ✅ ROUTE GUARD (simile a Angular CanActivate)
class AuthWrapper extends StatelessWidget 
{
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final authViewModel = Provider.of<AuthViewModel>(context);
    
    // Se l'utente è autenticato, va alla dashboard
    if (authViewModel.isAuthenticated) 
    {
      return const DashboardScreen();
    }
    // Altrimenti alla login
    return const LoginScreen();
  }
}