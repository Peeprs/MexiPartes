import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/usuario_model.dart';
import '../services/api_services.dart';
import '../services/firebase_notification_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final _secureStorage = const FlutterSecureStorage();

  Usuario? _usuarioActual;
  bool _isLoading = false;
  bool _isInitializing = true; // Nuevo: Para controlar la carga inicial
  String? _errorMessage;
  bool _isGuest = false;

  // Getters
  Usuario? get usuarioActual => _usuarioActual;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _usuarioActual != null || _isGuest;
  bool get isGuest => _isGuest;

  // CONSTRUCTOR: Cargar sesión al iniciar
  AuthProvider() {
    _cargarUsuarioLocal();
  }

  Future<void> loginAsGuest() async {
    _usuarioActual = null;
    _isGuest = true;
    await _secureStorage.write(key: 'is_guest', value: 'true');
    notifyListeners();
  }

  // ---------------------------------------------------------
  // PERSISTENCIA (Shared Preferences)
  // ---------------------------------------------------------
  Future<void> _cargarUsuarioLocal() async {
    try {
      final guestStr = await _secureStorage.read(key: 'is_guest');
      _isGuest = guestStr == 'true';

      final String? usuarioJson = await _secureStorage.read(key: 'datos_usuario');
      if (usuarioJson != null) {
        _usuarioActual = Usuario.fromJson(jsonDecode(usuarioJson));
        // Si hay usuario guardado, forzamos que NO sea invitado
        // Esto corrige el bug donde al reiniciar aparecía como invitado.
        if (_usuarioActual != null) {
          // Si el ID es "0", es un relicto de la lógica antigua (int). Invalidamos sesión.
          if (_usuarioActual!.id == '0') {
            _usuarioActual = null;
            _borrarUsuarioLocal();
            _isGuest = false;
          } else {
            _isGuest = false;
            // Re-registrar token al cargar sesión guardada
            FirebaseNotificationService().initialize(_usuarioActual!.id);
          }
        }
      }
    } catch (e) {
      debugPrint("Error cargando usuario: $e");
    } finally {
      // Indicamos que terminó la inicialización
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> _guardarUsuarioLocal(Usuario usuario) async {
    String datos = jsonEncode(usuario.toJson());
    await _secureStorage.write(key: 'datos_usuario', value: datos);
    // IMPORTANTE: Si guardamos un usuario, ya no es invitado.
    await _secureStorage.write(key: 'is_guest', value: 'false');
  }

  Future<void> _borrarUsuarioLocal() async {
    await _secureStorage.delete(key: 'datos_usuario');
    await _secureStorage.delete(key: 'is_guest');
  }

  // ---------------------------------------------------------
  // LÓGICA DE NEGOCIO
  // ---------------------------------------------------------

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // 1. LOGIN
  Future<bool> login(String correo, String pwd) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final usuario = await _apiService.validateUsuario(correo, pwd);

      if (usuario != null) {
        _usuarioActual = usuario;
        await _guardarUsuarioLocal(usuario);

        // Registrar Token FCM
        await FirebaseNotificationService().initialize(usuario.id);

        FirebaseCrashlytics.instance.setUserIdentifier(usuario.id);

        _isGuest = false;
        _setLoading(false);
        return true;
      } else {
        _errorMessage = "Correo o contraseña incorrectos.";
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = "Error de conexión. Intenta más tarde.";
      _setLoading(false);
      return false;
    }
  }

  // 2. REGISTRO
  Future<bool> register({
    required String nombre,
    required String apellidoPaterno,
    String? apellidoMaterno,
    required String correo,
    required String pwd,
    bool esVendedor = false,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    // Verificar duplicados
    bool existe = await _apiService.checkUsuarioExists(correo: correo);
    if (existe) {
      _errorMessage = "El correo ya está registrado.";
      _setLoading(false);
      return false;
    }

    Usuario nuevoUsuario = Usuario(
      strNombre: nombre,
      strApellidoPaterno: apellidoPaterno,
      strApellidoMaterno: apellidoMaterno,
      strCorreo: correo,
      strPassword: pwd, // IMPORTANTE: Debe coincidir con tu modelo actualizado
      bitEsVendedor: esVendedor,
    );

    try {
      final usuarioCreado = await _apiService.createUsuario(nuevoUsuario);

      if (usuarioCreado != null) {
        // Auto-login al registrar
        _usuarioActual = usuarioCreado;
        await _guardarUsuarioLocal(usuarioCreado);
        _setLoading(false);
        return true;
      } else {
        _errorMessage = "No se pudo crear el usuario.";
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = "Error al registrar: $e";
      _setLoading(false);
      return false;
    }
  }

  // 3. ELIMINAR CUENTA (Nuevo)
  Future<bool> deleteAccount(String password) async {
    if (_usuarioActual == null) return false;

    _setLoading(true);
    // Asumimos que agregaste deleteAccount en ApiService
    final success = await _apiService.deleteAccount(
      _usuarioActual!.id,
      password,
    );

    if (success) {
      logout(); // Si se borró en BD, limpiamos la app
    } else {
      // Si falla, probablemente la contraseña estaba mal
      _errorMessage = "No se pudo eliminar. Verifica tu contraseña.";
    }

    _setLoading(false);
    return success;
  }

  // 6. REFRESCAR USUARIO DESDE API
  Future<void> refreshUsuario() async {
    if (_usuarioActual == null) return;
    final u = await _apiService.getUsuarioById(_usuarioActual!.id);
    if (u != null) {
      _usuarioActual = u;
      await _guardarUsuarioLocal(u);
      notifyListeners();
    }
  }

  // 7. ACTUALIZAR USUARIO
  Future<bool> updateUsuario(Usuario usuario) async {
    _setLoading(true);
    final u = await _apiService.updateUsuario(usuario);
    _setLoading(false);
    if (u != null) {
      _usuarioActual = u;
      await _guardarUsuarioLocal(u);
      notifyListeners();
      return true;
    }
    _errorMessage = 'No se pudo actualizar el usuario.';
    return false;
  }

  // 4. RECUPERAR CONTRASEÑA (Nuevo)
  Future<bool> resetPassword(String email, String newPassword) async {
    _setLoading(true);
    _errorMessage = null;

    // Asumimos que agregaste recoverPassword en ApiService
    final success = await _apiService.recoverPassword(email, newPassword);

    if (!success) {
      _errorMessage = "No se encontró el correo o hubo un error.";
    }

    _setLoading(false);
    return success;
  }

  // 5. LOGOUT
  Future<void> logout() async {
    _usuarioActual = null;
    _isGuest = false;
    await _borrarUsuarioLocal();
    FirebaseCrashlytics.instance.setUserIdentifier('');
    notifyListeners();
  }
}
