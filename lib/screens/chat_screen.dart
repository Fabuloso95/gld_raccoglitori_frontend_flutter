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
  final String? titoloChat;

  const ChatScreen({
    super.key,
    this.gruppoId,
    this.altroUtenteId,
    required this.tipoChat,
    required this.utenteCorrenteId,
    this.titoloChat
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> 
{
  final TextEditingController _messaggioController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isInitialLoad = true;
  late String _effectiveGruppoId;

  @override
  void initState() 
  {
    super.initState();
    _calculateEffectiveGruppoId();
    WidgetsBinding.instance.addPostFrameCallback((_) 
    {
      _caricaStoricoChat();
    });
  }

  void _calculateEffectiveGruppoId() 
  {
    if (widget.tipoChat == 'GRUPPO') 
    {
      _effectiveGruppoId = widget.gruppoId ?? 'gruppo_generale';
    } 
    else if (widget.tipoChat == 'PRIVATA' && widget.altroUtenteId != null) 
    {
      int minId = widget.utenteCorrenteId < widget.altroUtenteId! 
          ? widget.utenteCorrenteId 
          : widget.altroUtenteId!;
      int maxId = widget.utenteCorrenteId > widget.altroUtenteId! 
          ? widget.utenteCorrenteId 
          : widget.altroUtenteId!;
      _effectiveGruppoId = 'privata_${minId}_${maxId}';
    } 
    else 
    {
      _effectiveGruppoId = 'gruppo_generale';
    }
    
    print('🔍 Gruppo ID calcolato: $_effectiveGruppoId');
  }

  void _caricaStoricoChat() 
  {
    final viewModel = context.read<ChatViewModel>();
    
    if (widget.tipoChat == 'GRUPPO') 
    {
      print('📥 Caricamento chat gruppo: $_effectiveGruppoId');
      viewModel.caricaChatGruppo(_effectiveGruppoId);
    } 
    else if (widget.tipoChat == 'PRIVATA' && widget.altroUtenteId != null) 
    {
      print('📥 Caricamento chat privata con utente: ${widget.altroUtenteId}');
      viewModel.caricaChatPrivata(widget.altroUtenteId!);
    }
    _isInitialLoad = false;
  }

  @override
  void dispose() 
  {
    _messaggioController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _getTitoloChat() {
    if (widget.titoloChat != null) return widget.titoloChat!;
    
    if (widget.tipoChat == 'GRUPPO') {
      return 'Chat Gruppo ${widget.gruppoId ?? ''}';
    } else {
      return 'Chat Privata';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitoloChat()),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
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
              builder: (context, viewModel, child) {
                // Scroll to bottom quando i messaggi cambiano
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                if (_isInitialLoad && viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Errore: ${viewModel.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
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

                if (messaggi.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nessun messaggio ancora',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        Text(
                          'Inizia la conversazione!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: messaggi.length,
                  itemBuilder: (context, index) {
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
      gruppoId: _effectiveGruppoId,
      tipoChat: widget.tipoChat,
      destinatarioId: widget.altroUtenteId,
      contenuto: testo.trim(),
    );

    print('📤 Invio messaggio - Tipo: ${widget.tipoChat}, GruppoId: $_effectiveGruppoId');

    final success = await viewModel.inviaMessaggio(request);

    if (success) 
    {
      _messaggioController.clear();
      _scrollToBottom();
      _caricaStoricoChat();
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
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, child) 
      {
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, -2),
                blurRadius: 4,
                color: Colors.grey.withOpacity(0.1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: viewModel.isLoading ? 'Invio in corso...' : 'Scrivi un messaggio...',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    enabled: !viewModel.isLoading,
                  ),
                  maxLines: null,
                  onSubmitted: viewModel.isLoading ? null : onInviaMessaggio,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: viewModel.isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                onPressed: viewModel.isLoading 
                    ? null 
                    : () => onInviaMessaggio(controller.text),
              ),
            ],
          ),
        );
      },
    );
  }
}