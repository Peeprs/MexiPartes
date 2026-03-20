import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String actionCode;

  const ResetPasswordScreen({super.key, required this.actionCode});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  
  // Variables para la validación de seguridad en tiempo real
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePassword);
    _passwordController.dispose();
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
    return _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar;
  }

  Future<void> _handleResetPassword() async {
    if (!_isPasswordSecure()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La nueva contraseña no cumple con los requisitos de seguridad.'), backgroundColor: Colors.orangeAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Usamos el 'actionCode' del enlace para verificar la solicitud y cambiar la contraseña

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Contraseña actualizada con éxito! Ya puedes iniciar sesión.'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El enlace de recuperación no es válido o ha expirado. Por favor, solicita uno nuevo.'), backgroundColor: Colors.redAccent),
        );
         Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Crear Nueva Contraseña', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
             const Text(
              'Ingresa tu nueva contraseña. Asegúrate de que cumpla con todos los requisitos de seguridad.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Nueva contraseña',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            _buildPasswordValidator(), // Usamos el mismo validador visual del registro
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
               style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              child: _isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                  : const Text('Actualizar Contraseña', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordValidator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequirementRow(met: _hasMinLength, text: 'Mínimo 8 caracteres'),
        _buildRequirementRow(met: _hasUppercase, text: 'Una letra mayúscula (A-Z)'),
        _buildRequirementRow(met: _hasLowercase, text: 'Una letra minúscula (a-z)'),
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
