import 'package:cached_network_image/cached_network_image.dart'; // <--- Importante para imágenes
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para inputFormatters
import 'package:image_picker/image_picker.dart'; // Para seleccionar foto
import 'package:provider/provider.dart';
import '../../models/usuario_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_services.dart';
import 'dart:io'; // <--- Importante para File

class UsuarioCrudScreen extends StatefulWidget {
  final Usuario? usuario;
  const UsuarioCrudScreen({super.key, this.usuario});

  @override
  State<UsuarioCrudScreen> createState() => _UsuarioCrudScreenState();
}

class _UsuarioCrudScreenState extends State<UsuarioCrudScreen> {
  // Controladores
  late TextEditingController _nombre;
  late TextEditingController _apellidoP;
  late TextEditingController _apellidoM;
  late TextEditingController _correo;
  late TextEditingController _password;

  // Estado
  bool _esVendedor = false;
  bool _isCreate = false;
  bool _obscurePassword = true; // Para ver/ocultar pass

  // Variables de validación de contraseña en tiempo real
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  final _api = ApiService();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile; // Archivo local de imagen seleccionada

  // --- FILTRO: SOLO LETRAS Y ESPACIOS (Bloquea números y símbolos en nombres) ---
  final _lettersOnlyFormatter = FilteringTextInputFormatter.allow(
    RegExp(r"[A-Za-zÁÉÍÓÚÜÑáéíóúüñ\s]"),
  );

  @override
  void initState() {
    super.initState();

    // Si usuario es null, es Creación.
    final targetUser = widget.usuario;
    _isCreate = targetUser == null;

    _nombre = TextEditingController(text: targetUser?.strNombre ?? '');
    _apellidoP = TextEditingController(
      text: targetUser?.strApellidoPaterno ?? '',
    );
    _apellidoM = TextEditingController(
      text: targetUser?.strApellidoMaterno ?? '',
    );
    _correo = TextEditingController(text: targetUser?.strCorreo ?? '');
    _esVendedor = targetUser?.bitEsVendedor ?? false;
    _password = TextEditingController();

    // Escuchar cambios en el password para validar en tiempo real
    _password.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _password.removeListener(_validatePassword);
    _nombre.dispose();
    _apellidoP.dispose();
    _apellidoM.dispose();
    _correo.dispose();
    _password.dispose();
    super.dispose();
  }

  // --- LÓGICA DE IMAGEN ---
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // Reducir tamaño
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // 1. VALIDACIÓN DE SEGURIDAD (Extensión)
        final String path = pickedFile.path.toLowerCase();
        if (!path.endsWith('.jpg') &&
            !path.endsWith('.jpeg') &&
            !path.endsWith('.png')) {
          _mostrarSnack('Formato no seguro. Solo usa JPG o PNG.', false);
          return;
        }

        // 2. VALIDACIÓN DE TAMAÑO (Manual si fuera necesario, image_picker ya comprime)
        final File file = File(pickedFile.path);
        final int sizeInBytes = await file.length();
        if (sizeInBytes > 5 * 1024 * 1024) {
          // 5MB
          _mostrarSnack('La imagen es demasiado pesada (Máx 5MB).', false);
          return;
        }

        // 3. ADVERTENCIA DE SEGURIDAD VISUAL
        // No podemos escanear virus en local fácilmente, pero filtramos extensiones.

        setState(() {
          _imageFile = file;
        });
      }
    } catch (e) {
      _mostrarSnack('Error al seleccionar imagen: $e', false);
    }
  }

  // --- LÓGICA DE VALIDACIÓN SEGURA ---
  void _validatePassword() {
    final password = _password.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool _isPasswordSecure() {
    return _hasMinLength &&
        _hasUppercase &&
        _hasLowercase &&
        _hasNumber &&
        _hasSpecialChar;
  }

  Future<void> _procesarGuardado() async {
    // 1. Cerrar teclado
    FocusScope.of(context).unfocus();

    // 2. Validaciones básicas de campos vacíos
    if (_nombre.text.trim().isEmpty ||
        _apellidoP.text.trim().isEmpty ||
        _correo.text.trim().isEmpty) {
      _mostrarSnack('Por favor completa los campos obligatorios (*)', false);
      return;
    }

    // 3. Validaciones de formato (Regex)
    // Nota: Aunque el inputFormatter bloquea la entrada, validamos por seguridad.
    final nameRegex = RegExp(r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ\s]+$");
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!nameRegex.hasMatch(_nombre.text.trim()) ||
        !nameRegex.hasMatch(_apellidoP.text.trim())) {
      _mostrarSnack('Nombre y Apellido solo deben contener letras', false);
      return;
    }

    if (!emailRegex.hasMatch(_correo.text.trim())) {
      _mostrarSnack('Ingresa un correo electrónico válido', false);
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final passwordInput = _password.text.trim();

    // ============================================
    // LÓGICA MODO CREAR
    // ============================================
    if (_isCreate) {
      if (passwordInput.isEmpty) {
        _mostrarSnack('La contraseña es obligatoria', false);
        return;
      }
      if (!_isPasswordSecure()) {
        _mostrarSnack(
          'La contraseña no cumple con los requisitos de seguridad',
          false,
        );
        return;
      }

      final nuevo = Usuario(
        strNombre: _nombre.text.trim(),
        strApellidoPaterno: _apellidoP.text.trim(),
        strApellidoMaterno: _apellidoM.text.trim().isEmpty
            ? null
            : _apellidoM.text.trim(),
        strCorreo: _correo.text.trim(),
        strPassword: passwordInput,
        bitEsVendedor: _esVendedor,
        // Foto URL va nula al principio
      );

      try {
        _mostrarSnack('Creando usuario...', true); // Feedback visual

        // 1. Crear usuario base en Auth + Profile
        final creado = await _api.createUsuario(nuevo);

        if (creado != null) {
          // 2. Si hay imagen seleccionada, subirla y actualizar perfil
          if (_imageFile != null) {
            _mostrarSnack('Subiendo foto de perfil...', true);
            final photoUrl = await _api.uploadProfileImage(
              creado.id,
              _imageFile!,
            );

            if (photoUrl != null) {
              // Actualizar usuario con la URL de la foto
              final usuarioConFoto = Usuario(
                id: creado.id,
                strNombre: creado.strNombre,
                strApellidoPaterno: creado.strApellidoPaterno,
                strApellidoMaterno: creado.strApellidoMaterno,
                strCorreo: creado.strCorreo,
                bitEsVendedor: creado.bitEsVendedor,
                strFotoUrl: photoUrl, // <--- URL DE FOTO
              );
              await _api.updateUsuario(usuarioConFoto);
            }
          }

          if (!mounted) return;
          _mostrarSnack('Usuario creado con éxito', true);
          Navigator.pop(context);
        }
      } catch (e) {
        // AQUÍ CAPTURAMOS EL MENSAJE "El correo ya está registrado"
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        _mostrarSnack(errorMsg, false);
      }
      return;
    }

    // ============================================
    // LÓGICA MODO EDITAR
    // ============================================
    if (widget.usuario != null) {
      if (passwordInput.isEmpty) {
        _mostrarSnack('Confirma tu contraseña para guardar cambios', false);
        return;
      }
      if (!_isPasswordSecure()) {
        _mostrarSnack(
          'La contraseña no cumple con los requisitos de seguridad',
          false,
        );
        return;
      }

      try {
        String? finalPhotoUrl = widget.usuario!.strFotoUrl;

        // 1. Si hay nueva imagen, subirla primero
        if (_imageFile != null) {
          _mostrarSnack('Subiendo nueva foto...', true);
          final url = await _api.uploadProfileImage(
            widget.usuario!.id,
            _imageFile!,
          );
          if (url != null) {
            finalPhotoUrl = url;
          }
        }

        final usuarioEditado = Usuario(
          id: widget.usuario!.id,
          strNombre: _nombre.text.trim(),
          strApellidoPaterno: _apellidoP.text.trim(),
          strApellidoMaterno: _apellidoM.text.trim().isEmpty
              ? null
              : _apellidoM.text.trim(),
          strCorreo: _correo.text.trim(),
          bitEsVendedor: _esVendedor,
          strPassword: passwordInput,
          strFotoUrl: finalPhotoUrl, // <--- FOTO FINAL
        );

        final ok = await auth.updateUsuario(usuarioEditado);

        if (!mounted) return;

        if (ok) {
          _mostrarSnack('Datos actualizados correctamente', true);
          Navigator.pop(context);
        } else {
          _mostrarSnack(auth.errorMessage ?? 'Error al actualizar', false);
        }
      } catch (e) {
        _mostrarSnack('Error al editar: $e', false);
      }
    }
  }

  void _mostrarSnack(String msg, bool exito) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: exito ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          _isCreate ? 'Crear Usuario' : 'Editar Usuario',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // --- SELECCIONAR FOTO DE PERFIL ---
              GestureDetector(
                onTap: _isCreate
                    ? null
                    : _pickImage, // Solo editar si ya existe usuario (o habilitar para crear también)
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (widget.usuario?.strFotoUrl != null &&
                                widget.usuario!.strFotoUrl!.isNotEmpty)
                          ? CachedNetworkImageProvider(
                              widget.usuario!.strFotoUrl!,
                            )
                          : null, // Si no hay local ni remota
                      child:
                          (_imageFile == null &&
                              (widget.usuario?.strFotoUrl == null ||
                                  widget.usuario!.strFotoUrl!.isEmpty))
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_imageFile != null)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Imagen seleccionada (Local)",
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),

              TextField(
                controller: _nombre,
                style: const TextStyle(color: Colors.white),
                // BLOQUEO DE NÚMEROS/SÍMBOLOS
                inputFormatters: [_lettersOnlyFormatter],
                decoration: _dec(label: 'Nombre *'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _apellidoP,
                style: const TextStyle(color: Colors.white),
                // BLOQUEO DE NÚMEROS/SÍMBOLOS
                inputFormatters: [_lettersOnlyFormatter],
                decoration: _dec(label: 'Apellido Paterno *'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _apellidoM,
                style: const TextStyle(color: Colors.white),
                // BLOQUEO DE NÚMEROS/SÍMBOLOS
                inputFormatters: [_lettersOnlyFormatter],
                decoration: _dec(label: 'Apellido Materno (Opcional)'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _correo,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: _dec(label: 'Correo Electrónico *'),
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _password,
                obscureText: _obscurePassword, // Variable de visibilidad
                style: const TextStyle(color: Colors.white),
                decoration: _dec(
                  label: _isCreate
                      ? 'Contraseña (Obligatoria) *'
                      : 'Contraseña (Confirma para guardar) *',
                  isPassword: true, // Activa el ícono de ojo
                ),
                textInputAction: TextInputAction.done,
              ),

              // Mostrar validaciones visuales si está escribiendo pass o es crear
              if (_isCreate || _password.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildPasswordValidator(),
              ],

              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text(
                  'Es Vendedor',
                  style: TextStyle(color: Colors.white),
                ),
                value: _esVendedor,
                onChanged: (v) => setState(() => _esVendedor = v),
                activeThumbColor: Colors.white,
                activeTrackColor: Colors.grey,
              ),
              const SizedBox(height: 24),

              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _procesarGuardado,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : Text(
                              _isCreate ? 'Crear Usuario' : 'Guardar Cambios',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),

              if (!_isCreate && widget.usuario != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'ID Usuario: ${widget.usuario!.id}',
                    style: const TextStyle(color: Colors.white38),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER DECORACIÓN INPUT ---
  InputDecoration _dec({required String label, bool isPassword = false}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      // Ícono de ojo para contraseña
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.white54,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            )
          : null,
    );
  }

  // --- HELPER VISUAL DE CONTRASEÑA ---
  Widget _buildPasswordValidator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Requisitos de seguridad:',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementRow(met: _hasMinLength, text: 'Mínimo 8 caracteres'),
          _buildRequirementRow(
            met: _hasUppercase,
            text: 'Una letra mayúscula (A-Z)',
          ),
          _buildRequirementRow(
            met: _hasLowercase,
            text: 'Una letra minúscula (a-z)',
          ),
          _buildRequirementRow(met: _hasNumber, text: 'Un número (0-9)'),
          _buildRequirementRow(
            met: _hasSpecialChar,
            text: 'Un símbolo (!@#\$%)',
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementRow({required bool met, required String text}) {
    final color = met ? Colors.greenAccent : Colors.grey;
    final icon = met ? Icons.check_circle : Icons.circle_outlined;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }
}
