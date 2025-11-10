// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/book_details_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/crea_utente_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/lista_chat_screen.dart';
import 'screens/lista_commenti_screen.dart';
import 'screens/lista_utenti_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/commenti_api_service.dart';
import 'services/curiosita_api_service.dart';
import 'services/frase_preferita_api_service.dart';
import 'services/lettura_corrente_api_service.dart';
import 'services/libro_api_service.dart';
import 'services/messaggio_chat_api_service.dart';
import 'services/proposta_voto_api_service.dart';
import 'services/raccoglitori_api_service.dart';
import 'services/utente_api_service.dart';
import 'services/voto_utente_api_service.dart';
import 'view_models/chat_view_model.dart';
import 'view_models/commenti_view_model.dart';
import 'view_models/utente_view_model.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
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
      ],
      child: const GDLApp(),
    ),
  );
}

class GDLApp extends StatelessWidget {
  const GDLApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        '/': (context) => const AuthWrapper(), // Gestisce login/auto-login
        '/dashboard': (context) => const DashboardScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/home': (context) => const HomeScreen(),
        '/utenti': (context) => const ListaUtentiScreen(),
        '/chat': (context) => const ListaChatScreen(),
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
            
            if (utenteCorrenteId == null) {
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
          //case '/book-details':
            //return MaterialPageRoute(builder: (_) => const BookDetailsScreen(bookId: ,));
          //case '/voting':
           // return MaterialPageRoute(builder: (_) => const VotingScreen());
          // Aggiungi altre routes lazy qui...
        }
        return null;
      },
    );
  }
}

// ✅ ROUTE GUARD (simile a Angular CanActivate)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    // Se l'utente è autenticato, va alla dashboard
    if (authService.isAuthenticated) {
      return const DashboardScreen();
    }
    // Altrimenti alla login
    return const LoginScreen();
  }
}