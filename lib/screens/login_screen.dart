import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/auth_view_model.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget 
{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> 
{
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() 
  {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accesso GDL Raccoglitori'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
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
                    size: 80,
                    color: Color(0xFF1E88E5),
                  ),
                  const SizedBox(height: 16),
                  
                  // Titolo
                  const Text(
                    'Benvenuto',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Accedi al tuo account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Campo Username/Email
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username o Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    ),
                    validator: (value) 
                    {
                      if (value == null || value.isEmpty) 
                      {
                        return 'Inserisci username o email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Campo Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () 
                        {
                          setState(() 
                          {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    ),
                    validator: (value) 
                    {
                      if (value == null || value.isEmpty) 
                      {
                        return 'Inserisci la password';
                      }
                      if (value.length < 6) 
                      {
                        return 'La password deve essere di almeno 6 caratteri';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  // Link password dimenticata
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implementare recupero password
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Funzionalità di recupero password in sviluppo'),
                          ),
                        );
                      },
                      child: const Text('Password dimenticata?'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Bottone di Login
                  Consumer<AuthViewModel>(
                    builder: (context, viewModel, child) 
                    {
                      // Mostra errori
                      if (viewModel.error != null) 
                      {
                        WidgetsBinding.instance.addPostFrameCallback((_) 
                        {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(viewModel.error!),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                          viewModel.clearError();
                        });
                      }
                      
                      // Mostra successo
                      if (viewModel.successMessage != null) 
                      {
                        WidgetsBinding.instance.addPostFrameCallback((_) 
                        {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(viewModel.successMessage!),
                              backgroundColor: Colors.green,
                            ),
                          );
                          viewModel.clearSuccess();
                        });
                      }
                      
                      return Column(
                        children: [
                          if (viewModel.isLoading)
                            const CircularProgressIndicator()
                          else
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E88E5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  'Accedi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _handleGoogleLogin,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      icon: const FaIcon(FontAwesomeIcons.google, size: 20, color: Colors.red),
                      label: const Text(
                        'Accedi con Google',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Divisore
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OPPURE',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Link per la Registrazione
                  OutlinedButton(
                    onPressed: () 
                    {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegistrationScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: Color(0xFF1E88E5)),
                    ),
                    child: const Text(
                      'Crea un nuovo account',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1E88E5),
                        fontWeight: FontWeight.w500,
                      ),
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

  Future<void> _handleLogin() async 
  {
    if (!_formKey.currentState!.validate()) 
    {
      return;
    }

    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success) 
    {
      // La navigazione viene gestita automaticamente da AuthWrapper
      _formKey.currentState?.reset();
    }
  }

  Future<void> _handleGoogleLogin() async {
    final viewModel = context.read<AuthViewModel>();
    await viewModel.loginWithGoogle();
  }
}