import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/evento_view_model.dart';
import '../widgets/calendario_mensile.dart';
import '../widgets/lista_eventi_giorno.dart';
import '../widgets/prossimi_eventi_card.dart';
import 'crea_evento_screen.dart';

class CalendarioScreen extends StatefulWidget 
{
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> 
{
  DateTime _selectedDate = DateTime.now();
  bool _isInitialLoad = true;

  @override
  void initState() 
  {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) 
    {
      _loadEventi();
    });
  }

  void _loadEventi() 
  {
    final viewModel = context.read<EventoViewModel>();
    viewModel.caricaEventiMensili(_selectedDate.year, _selectedDate.month);
    viewModel.caricaProssimiEventi();
    _isInitialLoad = false;
  }

  void _onDateSelected(DateTime date) 
  {
    setState(() 
    {
      _selectedDate = date;
    });
  }

  void _onMonthChanged(DateTime date) 
  {
    final viewModel = context.read<EventoViewModel>();
    viewModel.caricaEventiMensili(date.year, date.month);
  }

  void _navigaACreaEvento() 
  {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreaEventoScreen(
          dataIniziale: _selectedDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) 
  {
    final authViewModel = context.watch<AuthViewModel>();
    final isAdmin = authViewModel.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario GDL'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _navigaACreaEvento,
            ),
        ],
      ),
      body: Consumer<EventoViewModel>(
        builder: (context, viewModel, child) 
        {
          if (_isInitialLoad && viewModel.isLoading) 
          {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) 
          {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Errore: ${viewModel.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadEventi,
                    child: const Text('Riprova'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: 
            [
              const ProssimiEventiCard(),
              
              // Divisore
              Container(
                height: 1,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
              
              // Header con data selezionata
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.today),
                      onPressed: () 
                      {
                        final now = DateTime.now();
                        setState(() 
                        {
                          _selectedDate = now;
                        });
                        _onMonthChanged(now);
                      },
                    ),
                  ],
                ),
              ),
              
              // Calendario e lista eventi
              Expanded(
                child: Column(
                  children: [
                    // Calendario più compatto
                    Expanded(
                      flex: 2,
                      child: CalendarioMensile(
                        selectedDate: _selectedDate,
                        onDateSelected: _onDateSelected,
                        onMonthChanged: _onMonthChanged,
                      ),
                    ),
                    // Lista eventi più compatta
                    Expanded(
                      flex: 1,
                      child: ListaEventiGiorno(selectedDate: _selectedDate),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _navigaACreaEvento,
              backgroundColor: const Color(0xFF1E88E5),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}