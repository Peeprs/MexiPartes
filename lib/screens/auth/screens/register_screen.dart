import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart'; // Necesario para inputFormatters
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _isSeller = false;

  // Variables para los mensajes de error visuales
  String? _emailError;
  String? _passwordError;
  String? _termsError;

  // Variables para la validación de contraseña en tiempo real
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNamePaternalController = TextEditingController();
  final _lastNameMaternalController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Formatter para permitir solo letras y espacios
  final _lettersOnlyFormatter = FilteringTextInputFormatter.allow(
    RegExp(r"[A-Za-zÁÉÍÓÚÜÑáéíóúüñ\s]"),
  );

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePassword);
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _lastNamePaternalController.dispose();
    _lastNameMaternalController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;
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

  Future<void> _handleRegister() async {
    // 1. Limpiar errores previos
    setState(() {
      _emailError = null;
      _passwordError = null;
      _termsError = null;
    });

    // 2. Validaciones Locales
    if (!_acceptTerms) {
      setState(
        () => _termsError = 'Debes aceptar los términos para continuar.',
      );
      return;
    }

    final nombre = _nameController.text.trim();
    final apellidoP = _lastNamePaternalController.text.trim();
    final apellidoM = _lastNameMaternalController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (nombre.isEmpty || apellidoP.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nombre y Apellido Paterno son obligatorios.'),
        ),
      );
      return;
    }

    // Validación de formato de email simple y robusta
    final bool isEmailValid = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);
    if (!isEmailValid) {
      setState(() => _emailError = 'Por favor, ingresa un correo válido.');
      return;
    }

    if (!_isPasswordSecure()) {
      setState(
        () => _passwordError = 'La contraseña no cumple con los requisitos.',
      );
      return;
    }

    if (password != confirm) {
      setState(() => _passwordError = 'Las contraseñas no coinciden.');
      return;
    }

    // 3. Llamada al Provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Ocultar teclado antes de enviar
    FocusScope.of(context).unfocus();

    final success = await authProvider.register(
      nombre: nombre,
      apellidoPaterno: apellidoP,
      apellidoMaterno: apellidoM.isEmpty ? null : apellidoM,
      correo: email,
      pwd: password,
      esVendedor: _isSeller,
    );

    if (success && mounted) {
      // ÉXITO
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada!'),
          backgroundColor: Colors.green,
        ),
      );

      // Si tu AuthProvider hace auto-login, el AuthWrapper cambiará la pantalla solo.
      // Si NO hace auto-login, mandamos al usuario a loguearse:
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // ERROR (Mostrar mensaje del servidor)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Error al registrar.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Crear Cuenta',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Diseño responsivo básico
            final contentWidth = constraints.maxWidth > 600
                ? constraints.maxWidth * 0.6
                : constraints.maxWidth;

            return Center(
              child: SizedBox(
                width: contentWidth,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  children: [
                    const Text(
                      'Únete a MexiPartes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gestiona tus pedidos y compras',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // --- CAMPOS DE TEXTO ---
                    _buildLabel('Nombre'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      inputFormatters: [_lettersOnlyFormatter],
                      decoration: _buildInputDecoration('Ej. Juan'),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Apellido Paterno'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _lastNamePaternalController,
                                style: const TextStyle(color: Colors.white),
                                inputFormatters: [_lettersOnlyFormatter],
                                decoration: _buildInputDecoration('Ej. Pérez'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Apellido Materno'),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _lastNameMaternalController,
                                style: const TextStyle(color: Colors.white),
                                inputFormatters: [_lettersOnlyFormatter],
                                decoration: _buildInputDecoration('Ej. López'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Correo Electrónico'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildInputDecoration(
                        'ejemplo@correo.com',
                        prefixIcon: Icons.email_outlined,
                        errorText: _emailError,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Contraseña'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) => _validatePassword(),
                      decoration: _buildInputDecoration(
                        '••••••••',
                        prefixIcon: Icons.lock_outline,
                        errorText: _passwordError,
                        isPassword: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPasswordValidator(),
                    const SizedBox(height: 20),

                    _buildLabel('Confirmar Contraseña'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(
                        '••••••••',
                        prefixIcon: Icons.lock_outline,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- CHECKBOX VENDEDOR ---
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CheckboxListTile(
                        title: const Text(
                          "¿Quieres vender productos?",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          "Activa esto para crear tu tienda",
                          style: TextStyle(color: Colors.grey),
                        ),
                        value: _isSeller,
                        activeColor: Colors.white,
                        checkColor: Colors.black,
                        onChanged: (val) =>
                            setState(() => _isSeller = val ?? false),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- TÉRMINOS ---
                    // --- TÉRMINOS CON ENLACES ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (val) =>
                              setState(() => _acceptTerms = val ?? false),
                          checkColor: Colors.black,
                          fillColor: WidgetStateProperty.all(Colors.white),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: _termsError != null
                                      ? Colors.red
                                      : Colors.white,
                                  fontSize: 14,
                                ),
                                children: [
                                  const TextSpan(text: 'Acepto el '),
                                  TextSpan(
                                    text: 'Aviso de Privacidad',
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        final result =
                                            await Navigator.pushNamed(
                                              context,
                                              '/privacy_policy',
                                            );
                                        if (result == true && mounted) {
                                          setState(() => _acceptTerms = true);
                                        }
                                      },
                                  ),
                                  const TextSpan(text: ' y '),
                                  TextSpan(
                                    text: 'Cookies',
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        final result =
                                            await Navigator.pushNamed(
                                              context,
                                              '/cookie_notice',
                                            );
                                        if (result == true && mounted) {
                                          setState(() => _acceptTerms = true);
                                        }
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_termsError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, bottom: 16),
                        child: Text(
                          _termsError!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // --- BOTÓN REGISTRAR ---
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Premium Red
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.red.withValues(
                          alpha: 0.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 8,
                        shadowColor: Colors.red.withValues(alpha: 0.4),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'CREAR CUENTA',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "¿Ya tienes cuenta?",
                          style: TextStyle(color: Colors.white70),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Inicia sesión',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- HELPERS UI ---
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 13),
    ),
  );

  InputDecoration _buildInputDecoration(
    String hint, {
    IconData? prefixIcon,
    String? errorText,
    bool isPassword = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.grey[900],
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey[800]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: Colors.grey[600])
          : null,
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: Colors.grey[600],
              ),
              splashRadius: 20,
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            )
          : null,
      errorText: errorText,
    );
  }

  Widget _buildPasswordValidator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        _buildRequirementRow(met: _hasSpecialChar, text: 'Un símbolo (!@#\$%)'),
      ],
    );
  }

  Widget _buildRequirementRow({required bool met, required String text}) {
    final color = met ? Colors.greenAccent : Colors.grey;
    final icon = met ? Icons.check_circle : Icons.circle_outlined;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }
}
