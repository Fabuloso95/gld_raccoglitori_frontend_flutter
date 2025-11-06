// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/raccoglitori_api_service.dart';

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
      },
      
      // ✅ LAZY LOADING (simile a loadChildren in Angular)
      onGenerateRoute: (settings) {
        // Puoi caricare screen on-demand per performance
        switch (settings.name) {
          //case '/book-details':
           // return MaterialPageRoute(builder: (_) => const BookDetailsScreen());
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