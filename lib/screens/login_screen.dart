import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart'; 
import '../screens/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final errorMessage = await authService.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (errorMessage != null) {
      // Mostra un messaggio di errore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
      );
    } 
    // Se l'accesso è riuscito, il Consumer in main.dart naviga automaticamente ad HomeScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accesso GDL Raccoglitori'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Icona o logo
                  const Icon(
                    Icons.book_online,
                    size: 100,
                    color: Color(0xFF1E88E5),
                  ),
                  const SizedBox(height: 40),
                  
                  // Campo Username/Email
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username o Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci username o email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Campo Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inserisci la password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  
                  // Bottone di Login
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'Accedi',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                  const SizedBox(height: 20),
                  
                  // Link per la Registrazione
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                      );
                    },
                    child: const Text('Non hai un account? Registrati ora'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Schermata placeholder per l'home, per completare il setup
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard - GDL'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authService.logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Benvenuto, ${authService.currentUsername} (${authService.currentRole})!',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
