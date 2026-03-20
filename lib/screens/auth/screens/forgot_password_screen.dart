import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController(); // NUEVO CONTROLADOR
  
  // Para ver/ocultar contraseña
  bool _obscurePassword = true; 

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset() async {
    // 1. Ocultar teclado
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    // 2. Validaciones locales
    if (email.isEmpty) {
      _mostrarSnackBar('Por favor, ingresa tu correo electrónico.', Colors.orangeAccent);
      return;
    }

    final bool isEmailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    if (!isEmailValid) {
      _mostrarSnackBar('Por favor, ingresa un formato de correo válido.', Colors.orangeAccent);
      return;
    }

    final hasMinLength = newPassword.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(newPassword);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(newPassword);
    final hasNumber = RegExp(r'[0-9]').hasMatch(newPassword);
    final hasSpecial = RegExp(r'[!@#\$%\^&*(),.?":{}|<>]').hasMatch(newPassword);
    if (!(hasMinLength && hasUppercase && hasLowercase && hasNumber && hasSpecial)) {
      _mostrarSnackBar('La contraseña debe tener 8+ caracteres, mayúscula, minúscula, número y símbolo.', Colors.orangeAccent);
      return;
    }

    // 3. Llamada al Backend Real a través del Provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Llamamos a resetPassword (que a su vez llama a la API recover-password)
    final success = await authProvider.resetPassword(email, newPassword);

    if (mounted) {
      if (success) {
        _mostrarSnackBar('¡Contraseña actualizada! Ya puedes iniciar sesión.', Colors.green);
        // Esperamos un momento para que el usuario lea el mensaje y luego volvemos
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.of(context).pop();
      } else {
        // Mostramos el error que viene del Provider (ej: "Correo no existe")
        _mostrarSnackBar(authProvider.errorMessage ?? 'Ocurrió un error.', Colors.redAccent);
      }
    }
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado de carga del Provider
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.lock_reset, color: Theme.of(context).iconTheme.color, size: 80),
              const SizedBox(height: 30),
              Text(
                'Recuperar Contraseña',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Ingresa tu correo y define tu nueva contraseña para recuperar el acceso.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 40),
              
              // CAMPO CORREO
              Text('Correo Electrónico', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                // style removed
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Ingresa tu correo',
                  // filled removed
                  // fillColor removed
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              
              const SizedBox(height: 20),

              // NUEVO: CAMPO NUEVA CONTRASEÑA
              Text('Nueva Contraseña', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _newPasswordController,
                // style removed
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Define tu nueva clave',
                  // filled removed
                  // fillColor removed
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Theme.of(context).iconTheme.color ?? Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),
              
              // BOTÓN DE ACCIÓN
              ElevatedButton(
                onPressed: isLoading ? null : _handlePasswordReset,
                style: ElevatedButton.styleFrom(
                  // backgroundColor removed
                  // foregroundColor removed
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 3))
                    : const Text('Actualizar Contraseña', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
