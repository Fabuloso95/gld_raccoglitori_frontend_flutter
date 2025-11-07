import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';
import '../services/auth_service.dart';

class ListaChatScreen extends StatelessWidget 
{
  const ListaChatScreen({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: ListView(
        children: [
          // Chat di gruppo
          _ChatItem(
            titolo: 'Gruppo Lettura 2024',
            sottotitolo: 'Ultimo messaggio: Ciao a tutti!',
            tipo: 'GRUPPO',
            onTap: () 
            {
              _navigaAllaChat(
                context,
                gruppoId: 'gruppo-lettura-2024',
                tipoChat: 'GRUPPO',
              );
            },
          ),
          _ChatItem(
            titolo: 'Club del Libro',
            sottotitolo: 'Ultimo messaggio: Riunione domani',
            tipo: 'GRUPPO',
            onTap: () 
            {
              _navigaAllaChat(
                context,
                gruppoId: 'club-del-libro',
                tipoChat: 'GRUPPO',
              );
            },
          ),

          const Divider(),

          // Chat private
          _ChatItem(
            titolo: 'Mario Rossi',
            sottotitolo: 'Ultimo messaggio: Hai letto quel libro?',
            tipo: 'PRIVATA',
            onTap: () 
            {
              _navigaAllaChat(
                context,
                altroUtenteId: 1,
                tipoChat: 'PRIVATA',
              );
            },
          ),
          _ChatItem(
            titolo: 'Laura Bianchi',
            sottotitolo: 'Ultimo messaggio: Grazie per il consiglio!',
            tipo: 'PRIVATA',
            onTap: () 
            {
              _navigaAllaChat(
                context,
                altroUtenteId: 2,
                tipoChat: 'PRIVATA',
              );
            },
          ),
        ],
      ),
    );
  }

  // Metodo helper per navigare alla chat
  void _navigaAllaChat(BuildContext context, 
  {
    String? gruppoId,
    int? altroUtenteId,
    required String tipoChat,
  }) 
  {
    final authService = context.read<AuthService>();
    final utenteCorrenteId = authService.currentUserId;

    if (utenteCorrenteId == null) 
    {
      // Mostra un errore se l'utente non è loggato
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Devi essere loggato per accedere alla chat'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          gruppoId: gruppoId,
          altroUtenteId: altroUtenteId,
          tipoChat: tipoChat,
          utenteCorrenteId: utenteCorrenteId,
        ),
      ),
    );
  }
}

class _ChatItem extends StatelessWidget 
{
  final String titolo;
  final String sottotitolo;
  final String tipo;
  final VoidCallback onTap;

  const _ChatItem({
    required this.titolo,
    required this.sottotitolo,
    required this.tipo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) 
  {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: tipo == 'GRUPPO' ? Colors.blue : Colors.green,
        child: Icon(
          tipo == 'GRUPPO' ? Icons.group : Icons.person,
          color: Colors.white,
        ),
      ),
      title: Text(titolo),
      subtitle: Text(sottotitolo),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}