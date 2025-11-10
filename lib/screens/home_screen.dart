import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';

class HomeScreen extends StatelessWidget 
{
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) 
  {
    final authViewModel = Provider.of<AuthViewModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home - GDL Raccoglitori'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.home,
              size: 80,
              color: Color(0xFF1E88E5),
            ),
            const SizedBox(height: 20),
            Text(
              'Benvenuto, ${authViewModel.currentUsername}!',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              'Ruolo: ${authViewModel.currentRole ?? 'USER'}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () 
              {
                Navigator.pushNamed(context, '/dashboard');
              },
              child: const Text('Vai alla Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}