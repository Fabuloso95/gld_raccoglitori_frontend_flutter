import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/auth_view_model.dart';

class RegistrationScreen extends StatefulWidget 
{
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> 
{
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  bool _obscurePassword = true;

  // Pattern di validazione password
  static final RegExp _passwordPattern = RegExp(
    r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\p{Punct}]).*$", 
    unicode: true
  );

  @override
  void dispose() 
  {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nomeController.dispose();
    _cognomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea Account'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                  // Titolo
                  const Icon(
                    Icons.person_add_alt_1,
                    size: 80,
                    color: Color(0xFF1E88E5),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text(
                    'Crea il tuo account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  const Text(
                    'Unisciti alla nostra community di lettori',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Nome e Cognome in riga
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nomeController,
                          decoration: const InputDecoration(
                            labelText: 'Nome',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                          ),
                          validator: (v) => _validateRequired(v, 'Il nome'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _cognomeController,
                          decoration: const InputDecoration(
                            labelText: 'Cognome',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                          ),
                          validator: (v) => _validateRequired(v, 'Il cognome'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    ),
                    validator: (v) 
                    {
                      final req = _validateRequired(v, 'L\'username');
                      if (req != null) return req;
                      if (v!.length < 3 || v.length > 50) 
                      {
                        return 'Username tra 3 e 50 caratteri';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    ),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 20),
                  
                  // Password
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 10),
                  
                  // Requisiti password
                  _PasswordRequirements(),
                  const SizedBox(height: 30),
                  
                  // Bottone di Registrazione
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
                          // Torna al login dopo il successo
                          Future.delayed(const Duration(seconds: 2), () 
                          {
                            if (mounted) 
                            {
                              Navigator.of(context).pop();
                            }
                          });
                        });
                      }
                      
                      return Column(
                        children: [
                          if (viewModel.isLoading)
                            const CircularProgressIndicator()
                          else
                            ElevatedButton(
                              onPressed: _handleRegistration,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Crea Account',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Link per il Login
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Hai già un account? Accedi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegistration() async 
  {
    if (!_formKey.currentState!.validate()) 
    {
      return;
    }

    final viewModel = context.read<AuthViewModel>();
    final success = await viewModel.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      nome: _nomeController.text.trim(),
      cognome: _cognomeController.text.trim(),
    );

    if (success) 
    {
      _formKey.currentState?.reset();
    }
  }

  String? _validateRequired(String? value, String fieldName) 
  {
    if (value == null || value.isEmpty) 
    {
      return '$fieldName è obbligatorio.';
    }
    return null;
  }
  
  String? _validatePassword(String? value) 
  {
    if (value == null || value.length < 8) 
    {
      return 'La password deve essere lunga almeno 8 caratteri.';
    }
    if (!_passwordPattern.hasMatch(value)) 
    {
      return 'Deve contenere Maiuscola, Minuscola, Numero e Simbolo.';
    }
    return null;
  }
  
  String? _validateEmail(String? value) 
  {
    if (value == null || value.isEmpty) 
    {
      return 'L\'email è obbligatoria.';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) 
    {
      return 'Formato email non valido.';
    }
    return null;
  }
}

// Widget per i requisiti della password
class _PasswordRequirements extends StatelessWidget 
{
  @override
  Widget build(BuildContext context) 
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'La password deve contenere:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '• Almeno 8 caratteri',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          '• Una lettera maiuscola e una minuscola',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          '• Un numero',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          '• Un simbolo speciale',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}