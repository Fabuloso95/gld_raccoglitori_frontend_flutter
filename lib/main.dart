import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart'; 
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Forniamo l'AuthService a tutta l'applicazione per la gestione dello stato di login/token
        ChangeNotifierProvider(create: (_) => AuthService()),
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
          backgroundColor: Color(0xFF1E88E5), // Blue 600
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
        useMaterial3: true,
      ),
      home: Consumer<AuthService>(
        builder: (context, authService, child) {
          // Utilizziamo lo stato dell'AuthService per decidere quale schermata mostrare
          if (authService.isAuthenticated) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
