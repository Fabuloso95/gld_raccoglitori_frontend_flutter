import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/impostazioni_request.dart';
import '../view_models/impostazioni_view_model.dart';
import '../view_models/auth_view_model.dart';

class ImpostazioniScreen extends StatefulWidget 
{
  const ImpostazioniScreen({super.key});

  @override
  State<ImpostazioniScreen> createState() => _ImpostazioniScreenState();
}

class _ImpostazioniScreenState extends State<ImpostazioniScreen> 
{
  bool? _notificheEmail;
  bool? _notifichePush;
  bool? _emailRiassunto;
  bool? _privacyProfilo;
  String? _lingua;
  String? _tema;
  bool _hasChanges = false;
  bool _isLoading = false;
  bool _initialLoadComplete = false;

  @override
  void initState() 
  {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadImpostazioni();
    });
  }

  void _loadImpostazioni() 
  {
    if (!mounted) return;
    
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final impostazioniViewModel = Provider.of<ImpostazioniViewModel>(context, listen: false);
    final currentUserId = authViewModel.currentUserId;
    
    print('🔐 DEBUG - Caricamento impostazioni');
    print('🔐 DEBUG - User ID: $currentUserId');
    print('🔐 DEBUG - Username: ${authViewModel.currentUsername}');
    print('🔐 DEBUG - Is authenticated: ${authViewModel.isAuthenticated}');
    
    if (currentUserId != null) 
    {
      setState(() {
        _isLoading = true;
      });
      
      impostazioniViewModel.caricaImpostazioniUtente(currentUserId).then((_)
      {
        if (!mounted) return;
        
        if (impostazioniViewModel.impostazioni != null) 
        {
          setState(() 
          {
            _notificheEmail = impostazioniViewModel.impostazioni!.notificheEmail;
            _notifichePush = impostazioniViewModel.impostazioni!.notifichePush;
            _emailRiassunto = impostazioniViewModel.impostazioni!.emailRiassuntoSettimanale;
            _privacyProfilo = impostazioniViewModel.impostazioni!.privacyProfiloPubblico;
            _lingua = impostazioniViewModel.impostazioni!.lingua;
            _tema = impostazioniViewModel.impostazioni!.tema;
            _hasChanges = false;
            _initialLoadComplete = true;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _initialLoadComplete = true;
          });
        }
      }).catchError((error) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _initialLoadComplete = true;
        });
      });
    } else {
      setState(() {
        _isLoading = false;
        _initialLoadComplete = true;
      });
    }
  }

  void _markAsChanged() 
  {
    if (!_hasChanges) 
    {
      setState(() 
      {
        _hasChanges = true;
      });
    }
  }

  Future<void> _salvaImpostazioni() async 
  {
    if (!_hasChanges) return;
    
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUserId = authViewModel.currentUserId;
    
    if (currentUserId == null) 
    {
      if (mounted) 
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore: utente non autenticato'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    setState(() 
    {
      _isLoading = true;
    });
    
    final impostazioniViewModel = Provider.of<ImpostazioniViewModel>(context, listen: false);
    
    final request = ImpostazioniRequest(
      notificheEmail: _notificheEmail ?? true,
      notifichePush: _notifichePush ?? true,
      lingua: _lingua ?? 'it',
      tema: _tema ?? 'system',
      emailRiassuntoSettimanale: _emailRiassunto ?? false,
      privacyProfiloPubblico: _privacyProfilo ?? true,
    );
    
    try 
    {
      final success = await impostazioniViewModel.aggiornaImpostazioni(
        utenteId: currentUserId,
        request: request,
      );
      
      if (!mounted) return;
      
      setState(() 
      {
        _isLoading = false;
      });
      
      if (success) 
      {
        setState(() 
        {
          _hasChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impostazioni salvate con successo!'),
            backgroundColor: Colors.green,
          ),
        );
      } 
      else 
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore: ${impostazioniViewModel.error ?? "Errore sconosciuto"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } 
    catch (e) 
    {
      if (!mounted) return;
      
      setState(() 
      {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore di autenticazione: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _annullaModifiche() 
  {
    final impostazioniViewModel = Provider.of<ImpostazioniViewModel>(context, listen: false);
    if (impostazioniViewModel.impostazioni != null) 
    {
      setState(() 
      {
        _notificheEmail = impostazioniViewModel.impostazioni!.notificheEmail;
        _notifichePush = impostazioniViewModel.impostazioni!.notifichePush;
        _emailRiassunto = impostazioniViewModel.impostazioni!.emailRiassuntoSettimanale;
        _privacyProfilo = impostazioniViewModel.impostazioni!.privacyProfiloPubblico;
        _lingua = impostazioniViewModel.impostazioni!.lingua;
        _tema = impostazioniViewModel.impostazioni!.tema;
        _hasChanges = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    final impostazioniViewModel = Provider.of<ImpostazioniViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading || impostazioniViewModel.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
      body: _buildBody(impostazioniViewModel),
    );
  }

  Widget _buildBody(ImpostazioniViewModel impostazioniVM) 
  {
    if (_isLoading && !_initialLoadComplete) 
    {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (!_initialLoadComplete && impostazioniVM.error != null) 
    {
      return _buildErrorWidget(impostazioniVM);
    }
    
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (authViewModel.currentUserId == null) 
    {
      return _buildNotLoggedInWidget();
    }

    return RefreshIndicator(
      onRefresh: () async => _loadImpostazioni(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (impostazioniVM.saveSuccess)
              _buildSuccessBanner(),
            if (_hasChanges)
              _buildUnsavedChangesBanner(),
            _buildSectionTitle('Notifiche'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSwitchSetting(
                      title: 'Notifiche Email',
                      subtitle: 'Ricevi notifiche via email',
                      value: _notificheEmail ?? true,
                      onChanged: (value) 
                      {
                        setState(() 
                        {
                          _notificheEmail = value;
                          _markAsChanged();
                        });
                      },
                    ),
                    const Divider(),
                    _buildSwitchSetting(
                      title: 'Notifiche Push',
                      subtitle: 'Ricevi notifiche sull\'app',
                      value: _notifichePush ?? true,
                      onChanged: (value) 
                      {
                        setState(() 
                        {
                          _notifichePush = value;
                          _markAsChanged();
                        });
                      },
                    ),
                    const Divider(),
                    _buildSwitchSetting(
                      title: 'Riassunto Settimanale',
                      subtitle: 'Ricevi un riassunto email settimanale',
                      value: _emailRiassunto ?? false,
                      onChanged: (value) 
                      {
                        setState(() 
                        {
                          _emailRiassunto = value;
                          _markAsChanged();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Privacy'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSwitchSetting(
                      title: 'Profilo Pubblico',
                      subtitle: 'Rendi il tuo profilo visibile agli altri utenti',
                      value: _privacyProfilo ?? true,
                      onChanged: (value) 
                      {
                        setState(() 
                        {
                          _privacyProfilo = value;
                          _markAsChanged();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Preferenze App'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDropdownSetting(
                      title: 'Lingua',
                      subtitle: 'Seleziona la lingua dell\'app',
                      value: _lingua ?? 'it',
                      items: const [
                        DropdownMenuItem(value: 'it', child: Text('Italiano')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                      onChanged: (value) 
                      {
                        setState(() 
                        {
                          _lingua = value;
                          _markAsChanged();
                        });
                      },
                    ),
                    const Divider(),
                    _buildDropdownSetting(
                      title: 'Tema',
                      subtitle: 'Seleziona il tema dell\'app',
                      value: _tema ?? 'system',
                      items: const [
                        DropdownMenuItem(value: 'system', child: Text('Sistema')),
                        DropdownMenuItem(value: 'light', child: Text('Chiaro')),
                        DropdownMenuItem(value: 'dark', child: Text('Scuro')),
                      ],
                      onChanged: (value) 
                      {
                        setState(() 
                        {
                          _tema = value;
                          _markAsChanged();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildActionButtons(impostazioniVM),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) 
  {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E88E5),
        ),
      ),
    );
  }

  Widget _buildSwitchSetting({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF1E88E5),
        ),
      ],
    );
  }

  Widget _buildDropdownSetting({
    required String title,
    required String subtitle,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessBanner() 
  {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Impostazioni salvate con successo!',
              style: TextStyle(
                color: Colors.green[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsavedChangesBanner() 
  {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Hai modifiche non salvate',
              style: TextStyle(
                color: Colors.orange[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ImpostazioniViewModel impostazioniVM) 
  {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Errore: ${impostazioniVM.error}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadImpostazioni,
            child: const Text('Riprova'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedInWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Utente non autenticato',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Effettua il login per accedere alle impostazioni',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Vai al Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ImpostazioniViewModel impostazioniVM) 
  {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _hasChanges ? _annullaModifiche : _loadImpostazioni,
            child: Text(_hasChanges ? 'Annulla' : 'Ricarica'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _hasChanges && !_isLoading ? _salvaImpostazioni : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Salva'),
          ),
        ),
      ],
    );
  }
}