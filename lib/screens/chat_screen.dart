import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gld_raccoglitori/view_models/chat_view_model.dart';
import 'package:gld_raccoglitori/models/messaggio_chat_response.dart';
import 'package:gld_raccoglitori/models/MessaggioChatRequestModel.dart';

class ChatScreen extends StatefulWidget 
{
  final String? gruppoId;
  final int? altroUtenteId;
  final String tipoChat;
  final int utenteCorrenteId;

  const ChatScreen({
    super.key,
    this.gruppoId,
    this.altroUtenteId,
    required this.tipoChat,
    required this.utenteCorrenteId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> 
{
  final TextEditingController _messaggioController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() 
  {
    super.initState();
    _caricaStoricoChat();
  }

  void _caricaStoricoChat() 
  {
    final viewModel = context.read<ChatViewModel>();
    
    if (widget.tipoChat == 'GRUPPO' && widget.gruppoId != null) 
    {
      viewModel.caricaChatGruppo(widget.gruppoId!);
    } 
    else if (widget.tipoChat == 'PRIVATA' && widget.altroUtenteId != null) 
    {
      viewModel.caricaChatPrivata(widget.altroUtenteId!);
    }
  }

  @override
  void dispose() 
  {
    _messaggioController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() 
  {
    if (_scrollController.hasClients) 
    {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.tipoChat == 'GRUPPO' ? 'Chat Gruppo ${widget.gruppoId}' : 'Chat Privata',),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _caricaStoricoChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // Lista messaggi
          Expanded(
            child: Consumer<ChatViewModel>(
              builder: (context, viewModel, child) 
              {
                // Scroll to bottom quando i messaggi cambiano
                WidgetsBinding.instance.addPostFrameCallback((_) 
                {
                  _scrollToBottom();
                });

                if (viewModel.isLoading && viewModel.messaggiCorrenti.isEmpty) 
                {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.error != null) 
                {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Errore: ${viewModel.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        ElevatedButton(
                          onPressed: () 
                          {
                            viewModel.clearError();
                            _caricaStoricoChat();
                          },
                          child: const Text('Riprova'),
                        ),
                      ],
                    ),
                  );
                }

                final messaggi = viewModel.messaggiCorrenti;

                if (messaggi.isEmpty) 
                {
                  return const Center(
                    child: Text(
                      'Nessun messaggio ancora',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: messaggi.length,
                  itemBuilder: (context, index) 
                  {
                    final messaggio = messaggi[index];
                    return _MessaggioBubble(
                      messaggio: messaggio,
                      utenteCorrenteId: widget.utenteCorrenteId,
                    );
                  },
                );
              },
            ),
          ),

          // Input messaggio
          _InputMessaggio(
            controller: _messaggioController,
            onInviaMessaggio: _inviaMessaggio,
          ),
        ],
      ),
    );
  }

  Future<void> _inviaMessaggio(String testo) async 
  {
    if (testo.trim().isEmpty) return;

    final viewModel = context.read<ChatViewModel>();
    
    final request = MessaggioChatRequestModel(
      gruppoId: widget.gruppoId,
      tipoChat: widget.tipoChat,
      destinatarioId: widget.altroUtenteId,
      contenuto: testo.trim(),
    );

    final success = await viewModel.inviaMessaggio(request);

    if (success) 
    {
      _messaggioController.clear();
      _scrollToBottom();
    }
  }
}

// =============================================
// WIDGET PRIVATO _MessaggioBubble 
// =============================================
class _MessaggioBubble extends StatelessWidget 
{
  final MessaggioChatResponse messaggio;
  final int utenteCorrenteId;

  const _MessaggioBubble({
    required this.messaggio,
    required this.utenteCorrenteId,
  });

  @override
  Widget build(BuildContext context) 
  {
    // Determina se il mittente è l'utente corrente
    final isMittenteUtenteCorrente = messaggio.mittente.id == utenteCorrenteId;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isMittenteUtenteCorrente 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!isMittenteUtenteCorrente) 
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Text(
                messaggio.mittente.iniziale,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isMittenteUtenteCorrente 
                    ? Colors.blue.shade100 
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                crossAxisAlignment: isMittenteUtenteCorrente 
                    ? CrossAxisAlignment.end 
                    : CrossAxisAlignment.start,
                children: [
                  if (!isMittenteUtenteCorrente)
                    Text(
                      messaggio.mittente.nomeVisualizzato,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  Text(messaggio.contenuto),
                  const SizedBox(height: 4),
                  Text(
                    _formattaData(messaggio.dataInvio),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMittenteUtenteCorrente) 
            const SizedBox(width: 8),
          if (isMittenteUtenteCorrente)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: Text(
                messaggio.mittente.iniziale,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formattaData(DateTime data) 
  {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final ieri = today.subtract(const Duration(days: 1));
    final dataMessage = DateTime(data.year, data.month, data.day);

    if (dataMessage == today) 
    {
      return 'Oggi ${_formattaOra(data)}';
    } 
    else if (dataMessage == ieri) 
    {
      return 'Ieri ${_formattaOra(data)}';
    } 
    else 
    {
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')} ${_formattaOra(data)}';
    }
  }

  String _formattaOra(DateTime data) 
  {
    return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }
}

// =============================================
// WIDGET PRIVATO _InputMessaggio 
// =============================================
class _InputMessaggio extends StatelessWidget 
{
  final TextEditingController controller;
  final Function(String) onInviaMessaggio;

  const _InputMessaggio({
    required this.controller,
    required this.onInviaMessaggio,
  });

  @override
  Widget build(BuildContext context) 
  {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: const Color.fromARGB(28, 0, 0, 0),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Scrivi un messaggio...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
              maxLines: null,
              onSubmitted: onInviaMessaggio,
            ),
          ),
          const SizedBox(width: 8),
          Consumer<ChatViewModel>(
            builder: (context, viewModel, child) 
            {
              return IconButton(
                icon: viewModel.isLoading ? const CircularProgressIndicator() : const Icon(Icons.send),
                onPressed: viewModel.isLoading ? null : () => onInviaMessaggio(controller.text),
              );
            },
          ),
        ],
      ),
    );
  }
}