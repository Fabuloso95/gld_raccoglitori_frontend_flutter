import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/EventoRequest.dart';
import '../models/TipoEvento.dart';
import '../view_models/evento_view_model.dart';

class CreaEventoScreen extends StatefulWidget 
{
  final DateTime? dataIniziale;

  const CreaEventoScreen({super.key, this.dataIniziale});

  @override
  State<CreaEventoScreen> createState() => _CreaEventoScreenState();
}

class _CreaEventoScreenState extends State<CreaEventoScreen> 
{
  final _formKey = GlobalKey<FormState>();
  final _titoloController = TextEditingController();
  final _descrizioneController = TextEditingController();
  
  DateTime _dataInizio = DateTime.now();
  DateTime _dataFine = DateTime.now().add(const Duration(hours: 1));
  TipoEvento _tipoEvento = TipoEvento.INCONTRO;

  @override
  void initState() 
  {
    super.initState();
    if (widget.dataIniziale != null) 
    {
      _dataInizio = widget.dataIniziale!;
      _dataFine = _dataInizio.add(const Duration(hours: 1));
    }
  }

  Future<void> _selezionaDataInizio() async 
  {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
  );
  
  if (picked != null) 
  {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (time != null) 
    {
      DateTime finalDateTime = DateTime(
        picked.year, picked.month, picked.day,
        time.hour, time.minute
      );
    }
  }
}

  Future<void> _selezionaOraInizio() async 
  {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dataInizio),
    );
    if (picked != null) 
    {
      setState(() 
      {
        _dataInizio = DateTime(
          _dataInizio.year,
          _dataInizio.month,
          _dataInizio.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _selezionaDataFine() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataFine,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dataFine = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _dataFine.hour,
          _dataFine.minute,
        );
      });
    }
  }

  Future<void> _selezionaOraFine() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dataFine),
    );
    if (picked != null) {
      setState(() {
        _dataFine = DateTime(
          _dataFine.year,
          _dataFine.month,
          _dataFine.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _creaEvento() async {
    if (!_formKey.currentState!.validate()) return;

    final evento = EventoRequest(
      titolo: _titoloController.text,
      descrizione: _descrizioneController.text,
      dataInizio: _dataInizio,
      dataFine: _dataFine,
      tipoEvento: _tipoEvento,
    );

    final viewModel = context.read<EventoViewModel>();
    final success = await viewModel.creaEvento(evento);

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crea Nuovo Evento'),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titoloController,
                decoration: const InputDecoration(
                  labelText: 'Titolo Evento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci un titolo per l\'evento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descrizioneController,
                decoration: const InputDecoration(
                  labelText: 'Descrizione',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TipoEvento>(
                value: _tipoEvento,
                decoration: const InputDecoration(
                  labelText: 'Tipo Evento',
                  border: OutlineInputBorder(),
                ),
                items: TipoEvento.values.map((TipoEvento tipo) {
                  return DropdownMenuItem<TipoEvento>(
                    value: tipo,
                    child: Text(tipo.displayName),
                  );
                }).toList(),
                onChanged: (TipoEvento? newValue) {
                  setState(() {
                    _tipoEvento = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Data e Ora Inizio
              const Text('Data e Ora Inizio:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _selezionaDataInizio,
                      child: Text('${_dataInizio.day}/${_dataInizio.month}/${_dataInizio.year}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _selezionaOraInizio,
                      child: Text('${_dataInizio.hour.toString().padLeft(2, '0')}:${_dataInizio.minute.toString().padLeft(2, '0')}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Data e Ora Fine
              const Text('Data e Ora Fine:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _selezionaDataFine,
                      child: Text('${_dataFine.day}/${_dataFine.month}/${_dataFine.year}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _selezionaOraFine,
                      child: Text('${_dataFine.hour.toString().padLeft(2, '0')}:${_dataFine.minute.toString().padLeft(2, '0')}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Consumer<EventoViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: _creaEvento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Crea Evento'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}