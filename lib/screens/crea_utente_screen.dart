import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/utente_view_model.dart';
import 'package:gld_raccoglitori/models/UtenteRequestModel.dart';

class CreaUtenteScreen extends StatefulWidget 
{
  const CreaUtenteScreen({super.key});

  @override
  State<CreaUtenteScreen> createState() => _CreaUtenteScreenState();
}

class _CreaUtenteScreenState extends State<CreaUtenteScreen> 
{
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nomeController = TextEditingController();
  final _cognomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _ruoloSelezionato = 'USER';

  final List<String> _ruoliDisponibili = ['USER', 'ADMIN'];

  @override
  void dispose() 
  {
    _usernameController.dispose();
    _nomeController.dispose();
    _cognomeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea Nuovo Utente'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Consumer<UtenteViewModel>(
            builder: (context, viewModel, child) 
            {
              return Column(
                children: [
                  // Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) 
                    {
                      if (value == null || value.isEmpty) 
                      {
                        return 'Inserisci un username';
                      }
                      if (value.length < 3) 
                      {
                        return 'L\'username deve essere di almeno 3 caratteri';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Nome
                  TextFormField(
                    controller: _nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: (value) 
                    {
                      if (value == null || value.isEmpty) 
                      {
                        return 'Inserisci il nome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Cognome
                  TextFormField(
                    controller: _cognomeController,
                    decoration: const InputDecoration(
                      labelText: 'Cognome',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (value) 
                    {
                      if (value == null || value.isEmpty) 
                      {
                        return 'Inserisci il cognome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) 
                    {
                      if (value == null || value.isEmpty) 
                      {
                        return 'Inserisci l\'email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) 
                      {
                        return 'Inserisci un\'email valida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
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
                  const SizedBox(height: 16),

                  // Ruolo
                  DropdownButtonFormField<String>(
                    value: _ruoloSelezionato,
                    decoration: const InputDecoration(
                      labelText: 'Ruolo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.security),
                    ),
                    items: _ruoliDisponibili
                        .map((ruolo) => DropdownMenuItem(
                              value: ruolo,
                              child: Text(
                                ruolo,
                                style: TextStyle(
                                  fontWeight: ruolo == 'ADMIN'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: ruolo == 'ADMIN'
                                      ? Colors.red
                                      : Colors.black,
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (String? newValue) 
                    {
                      setState(() 
                      {
                        _ruoloSelezionato = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Pulsante di creazione
                  if (viewModel.isLoading)
                    const CircularProgressIndicator()
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _creaUtente,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Crea Utente',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                  // Mostra errori
                  if (viewModel.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () => viewModel.clearError(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _creaUtente() async 
  {
    if (_formKey.currentState!.validate()) 
    {
      final viewModel = context.read<UtenteViewModel>();

      final request = UtenteRequestModel(
        username: _usernameController.text.trim(),
        nome: _nomeController.text.trim(),
        cognome: _cognomeController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        ruolo: _ruoloSelezionato,
      );

      final success = await viewModel.creaUtente(request);

      if (success) 
      {
        // Mostra messaggio di successo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Utente creato con successo!'),
            backgroundColor: Colors.green,
          ),
        );

        // Torna indietro dopo un breve delay
        Future.delayed(const Duration(milliseconds: 1500), () 
        {
          if (mounted) 
          {
            Navigator.of(context).pop();
          }
        });
      }
    }
  }
}