import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/raccoglitori_api_service.dart'; // Importato
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() 
{
  runApp(
    MultiProvider(
      providers: [
        // AuthService: Fornito come ChangeNotifier per aggiornare l'UI (login/logout)
        ChangeNotifierProvider(create: (_) => AuthService()),

        // RaccoglitoriApiService: Fornito come Provider semplice.
        // Dipende da AuthService, che recuperiamo tramite context.read
        Provider<RaccoglitoriApiService>(
          create: (context) {
            final authService = context.read<AuthService>();
            // Passiamo l'AuthService per l'inizializzazione dell'AuthClient (Interceptor)
            return RaccoglitoriApiService(authService);
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
    return MaterialApp(
      title: 'GDL Raccoglitori',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E88E5), // Blue 600
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
        useMaterial3: true,
      ),
      home: Consumer<AuthService>(
        builder: (context, authService, child) 
        {
          // Utilizziamo lo stato dell'AuthService per decidere quale schermata mostrare
          if (authService.isAuthenticated) 
          {
            return const HomeScreen();
          } 
          else 
          {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
