import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/EventoResponse.dart';
import '../view_models/evento_view_model.dart';

class CalendarioMensile extends StatefulWidget 
{
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onMonthChanged;

  const CalendarioMensile({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  @override
  State<CalendarioMensile> createState() => _CalendarioMensileState();
}

class _CalendarioMensileState extends State<CalendarioMensile> 
{
  late DateTime _currentMonth;

  @override
  void initState() 
  {
    super.initState();
    _currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
  }

  void _previousMonth() 
  {
    setState(() 
    {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
    widget.onMonthChanged(_currentMonth);
  }

  void _nextMonth() 
  {
    setState(() 
    {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
    widget.onMonthChanged(_currentMonth);
  }

  @override
  Widget build(BuildContext context) 
  {
    final viewModel = context.watch<EventoViewModel>();
    
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Header mese più compatto
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: _previousMonth,
              ),
              Column(
                children: [
                  Text(
                    _getMonthName(_currentMonth.month),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _currentMonth.year.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: _nextMonth,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Giorni della settimana più compatti
          const Row(
            children: [
              Expanded(child: Center(child: Text('L', style: TextStyle(fontSize: 12)))),
              Expanded(child: Center(child: Text('M', style: TextStyle(fontSize: 12)))),
              Expanded(child: Center(child: Text('M', style: TextStyle(fontSize: 12)))),
              Expanded(child: Center(child: Text('G', style: TextStyle(fontSize: 12)))),
              Expanded(child: Center(child: Text('V', style: TextStyle(fontSize: 12)))),
              Expanded(child: Center(child: Text('S', style: TextStyle(fontSize: 12)))),
              Expanded(child: Center(child: Text('D', style: TextStyle(fontSize: 12)))),
            ],
          ),
          
          const SizedBox(height: 4),
          
          // Griglia giorni più compatta
          Expanded(
            child: _buildCalendarGrid(viewModel.eventi),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(List<EventoResponse> eventi) 
  {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startingWeekday = firstDay.weekday;
    final totalDays = lastDay.day;
    
    List<Widget> dayWidgets = [];

    // Aggiungi giorni vuoti per allineare il primo giorno
    for (int i = 1; i < startingWeekday; i++) 
    {
      dayWidgets.add(const SizedBox());
    }

    // Aggiungi i giorni del mese
    for (int day = 1; day <= totalDays; day++) 
    {
      final currentDate = DateTime(_currentMonth.year, _currentMonth.month, day);
      final hasEvents = _hasEventsOnDate(eventi, currentDate);
      
      dayWidgets.add(
        _buildDayCell(day, currentDate, hasEvents),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 3.8,
      ),
      itemCount: dayWidgets.length,
      itemBuilder: (context, index) => dayWidgets[index],
    );
  }

  Widget _buildDayCell(int day, DateTime date, bool hasEvents) 
  {
    final isSelected = date.day == widget.selectedDate.day &&
        date.month == widget.selectedDate.month &&
        date.year == widget.selectedDate.year;
    final isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    return GestureDetector(
      onTap: () => widget.onDateSelected(date),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E88E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: isToday ? Border.all(color: const Color(0xFF1E88E5), width: 1) : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (hasEvents)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 4, 
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _hasEventsOnDate(List<EventoResponse> eventi, DateTime date) 
  {
    return eventi.any((evento) 
    {
      final eventDate = evento.dataInizio;
      return eventDate.year == date.year &&
          eventDate.month == date.month &&
          eventDate.day == date.day;
    });
  }

  String _getMonthName(int month) 
  {
    switch (month)
    {
      case 1: return 'Gennaio';
      case 2: return 'Febbraio';
      case 3: return 'Marzo';
      case 4: return 'Aprile';
      case 5: return 'Maggio';
      case 6: return 'Giugno';
      case 7: return 'Luglio';
      case 8: return 'Agosto';
      case 9: return 'Settembre';
      case 10: return 'Ottobre';
      case 11: return 'Novembre';
      case 12: return 'Dicembre';
      default: return '';
    }
  }
}