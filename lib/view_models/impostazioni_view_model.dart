import 'package:flutter/foundation.dart';
import 'package:gld_raccoglitori/models/impostazioni_request.dart';
import 'package:gld_raccoglitori/models/impostazioni_response.dart';
import 'package:gld_raccoglitori/services/impostazioni_api_service.dart';

class ImpostazioniViewModel extends ChangeNotifier 
{
  final ImpostazioniApiService _impostazioniService;
  ImpostazioniResponse? _impostazioni;
  bool _isLoading = false;
  String? _error;
  bool _saveSuccess = false;

  ImpostazioniViewModel(this._impostazioniService);

  ImpostazioniResponse? get impostazioni => _impostazioni;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get saveSuccess => _saveSuccess;

  Future<void> caricaImpostazioniUtente(int utenteId) async 
  {
  _setLoading(true);
  _setError(null);
  try 
  {
    print('🔍 DEBUG - Inizio caricamento impostazioni');
    print('🔍 DEBUG - Utente ID: $utenteId');
    print('🔍 DEBUG - Service presente: ${_impostazioniService != null}');
    
    _impostazioni = await _impostazioniService.getImpostazioniUtente(utenteId);
    print('✅ DEBUG - Impostazioni caricate con successo');
    notifyListeners();
  } 
  catch (e) 
  {
    print('❌ DEBUG - Errore completo: $e');
    print('❌ DEBUG - Tipo errore: ${e.runtimeType}');
    
    if (e.toString().contains('Impostazioni non trovate') || e.toString().contains('404')) 
    {
      print('🔄 DEBUG - Tentativo creazione impostazioni default');
      await _creaImpostazioniDefault(utenteId);
    } 
    else if (e.toString().contains('401')) 
    {
      _setError('Non autorizzato - token mancante o scaduto');
    } 
    else 
    {
      _setError('Errore nel caricamento delle impostazioni: $e');
    }
  } 
  finally 
  {
    _setLoading(false);
  }
}

  Future<void> _creaImpostazioniDefault(int utenteId) async 
  {
    try 
    {
      _impostazioni = await _impostazioniService.createImpostazioniDefault(utenteId);
      notifyListeners();
    } 
    catch (e) 
    {
      _setError('Errore nella creazione delle impostazioni default: $e');
    }
  }

  Future<bool> aggiornaImpostazioni({required int utenteId, required ImpostazioniRequest request}) async 
  {
    _setLoading(true);
    _setError(null);
    _setSaveSuccess(false);
    try 
    {
      _impostazioni = await _impostazioniService.updateImpostazioni(
        utenteId: utenteId,
        request: request,
      );
      _setSaveSuccess(true);
      notifyListeners();
      return true;
    } 
    catch (e) 
    {
      _setError('Errore nell\'aggiornamento delle impostazioni: $e');
      return false;
    } 
    finally 
    {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) 
  {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) 
  {
    _error = error;
    notifyListeners();
  }

  void _setSaveSuccess(bool success) 
  {
    _saveSuccess = success;
    notifyListeners();
  }

  void clearError() 
  {
    _setError(null);
  }

  void clearSaveSuccess() 
  {
    _setSaveSuccess(false);
  }
}