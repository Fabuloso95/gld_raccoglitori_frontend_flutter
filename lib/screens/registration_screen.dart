import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart'; 

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  bool _isLoading = false;

  // Pattern di validazione password (corrisponde alla regex Java nel DTO)
  static final RegExp _passwordPattern = RegExp(
    r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\p{Punct}]).*$", 
    unicode: true
  );

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final errorMessage = await authService.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nome: _nomeController.text.trim(),
      cognome: _cognomeController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (errorMessage == null) {
      // Successo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrazione avvenuta con successo! Accedi ora.'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(); // Torna alla schermata di Login
    } else {
      // Errore (es. username/email già in uso)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
      );
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName è obbligatorio.';
    }
    return null;
  }
  
  String? _validatePassword(String? value) {
    if (value == null || value.length < 8) {
      return 'La password deve essere lunga almeno 8 caratteri.';
    }
    if (!_passwordPattern.hasMatch(value)) {
      return 'Deve contenere Maiusc, Minusc, Numero e Simbolo.';
    }
    return null;
  }
  
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email è obbligatoria.';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Formato email non valido.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrazione Nuovo Utente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // CAMPAGNA DI REGISTRAZIONE
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
                    validator: (v) => _validateRequired(v, 'Il nome'),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _cognomeController,
                    decoration: const InputDecoration(labelText: 'Cognome', border: OutlineInputBorder()),
                    validator: (v) => _validateRequired(v, 'Il cognome'),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                    validator: (v) {
                      final req = _validateRequired(v, 'L\'username');
                      if (req != null) return req;
                      if (v!.length < 3 || v.length > 50) return 'Username tra 3 e 50 caratteri';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 30),
                  
                  // Bottone di Registrazione
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _handleRegistration,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text(
                            'Registrati',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
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
