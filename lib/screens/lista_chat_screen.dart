import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';
import '../services/auth_service.dart';
import '../services/chat_list_service.dart';
import '../models/chat_preview.dart';

class ListaChatScreen extends StatefulWidget 
{
  const ListaChatScreen({super.key});

  @override
  State<ListaChatScreen> createState() => _ListaChatScreenState();
}

class _ListaChatScreenState extends State<ListaChatScreen> 
{
  @override
  void initState() 
  {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) 
    {
      context.read<ChatListService>().caricaChat();
    });
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ChatListService>().aggiorna(),
          ),
        ],
      ),
      body: Consumer<ChatListService>(
        builder: (context, chatListService, child) 
        {
          if (chatListService.isLoading) 
          {
            return _buildLoadingState();
          }

          if (chatListService.error != null) 
          {
            return _buildErrorState(chatListService.error!);
          }

          return _buildChatList(chatListService.chats);
        },
      ),
    );
  }

  Widget _buildLoadingState() 
  {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) => ListTile(
        leading: const CircleAvatar(backgroundColor: Colors.grey),
        title: Container(
          width: 100,
          height: 16,
          color: Colors.grey[300],
        ),
        subtitle: Container(
          width: 200,
          height: 14,
          color: Colors.grey[300],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) 
  {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Errore nel caricamento',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ChatListService>().aggiorna(),
            child: const Text('Riprova'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList(List<ChatPreview> chats) 
  {
    if (chats.isEmpty) 
    {
      return const Center(
        child: Text('Nessuna chat disponibile'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async 
      {
        await context.read<ChatListService>().caricaChat();
      },
      child: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) 
        {
          final chat = chats[index];
          return _ChatListItem(
            chat: chat,
            onTap: () => _navigaAllaChat(context, chat),
          );
        },
      ),
    );
  }

  void _navigaAllaChat(BuildContext context, ChatPreview chat) 
  {
    if (chat.gruppoId != null) 
    {
      context.read<ChatListService>().segnaComeLetta(chat.gruppoId!);
    } 
    else if (chat.altroUtenteId != null) 
    {
      context.read<ChatListService>().segnaPrivataComeLetta(chat.altroUtenteId!);
    }

    final authService = context.read<AuthService>();
    final utenteCorrenteId = authService.currentUserId;

    if (utenteCorrenteId == null) 
    {
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
          gruppoId: chat.gruppoId,
          altroUtenteId: chat.altroUtenteId,
          tipoChat: chat.tipoChat,
          utenteCorrenteId: utenteCorrenteId,
        ),
      ),
    ).then((_) 
    {
      context.read<ChatListService>().caricaChat();
    });
  }
}

class _ChatListItem extends StatelessWidget 
{
  final ChatPreview chat;
  final VoidCallback onTap;

  const _ChatListItem({
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) 
  {
    return ListTile(
      leading: _buildLeading(),
      title: Text(
        chat.titolo,
        style: TextStyle(
          fontWeight: chat.messaggiNonLetti > 0 
              ? FontWeight.bold 
              : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        chat.ultimoMessaggio ?? 'Nessun messaggio',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: chat.messaggiNonLetti > 0 
              ? FontWeight.w600 
              : FontWeight.normal,
          color: chat.messaggiNonLetti > 0 
              ? Colors.black87 
              : Colors.black54,
        ),
      ),
      trailing: _buildTrailing(),
      onTap: onTap,
    );
  }

  Widget _buildLeading() 
  {
    return Stack(
      children: [
        CircleAvatar(
          backgroundColor: chat.tipoChat == 'GRUPPO' 
              ? Colors.blue 
              : Colors.green,
          child: Icon(
            chat.tipoChat == 'GRUPPO' ? Icons.group : Icons.person,
            color: Colors.white,
          ),
        ),
        if (chat.messaggiNonLetti > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                chat.messaggiNonLetti > 99 
                    ? '99+' 
                    : chat.messaggiNonLetti.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTrailing() 
  {
    if (chat.dataUltimoMessaggio == null) 
    {
      return const SizedBox();
    }

    return Text(
      _formattaData(chat.dataUltimoMessaggio!),
      style: TextStyle(
        fontSize: 12,
        color: chat.messaggiNonLetti > 0 
            ? Colors.blue 
            : Colors.grey,
        fontWeight: chat.messaggiNonLetti > 0 
            ? FontWeight.bold 
            : FontWeight.normal,
      ),
    );
  }

  String _formattaData(DateTime data) 
  {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final ieri = today.subtract(const Duration(days: 1));

    if (data.isAfter(today)) 
    {
      return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    } 
    else if (data.isAfter(ieri)) 
    {
      return 'Ieri';
    } 
    else 
    {
      return '${data.day}/${data.month}';
    }
  }
}