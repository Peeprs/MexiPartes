import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Ocultar teclado
    FocusScope.of(context).unfocus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validaciones locales
    if (email.isEmpty || !email.contains('@')) {
      _mostrarSnackBar(
        'Ingresa un correo electrónico válido.',
        Colors.redAccent,
      );
      return;
    }
    if (password.isEmpty) {
      _mostrarSnackBar('Ingresa tu contraseña.', Colors.redAccent);
      return;
    }

    // Llamada al Backend
    final success = await authProvider.login(email, password);

    if (success && mounted) {
      // ✅ ÉXITO: Forzamos la navegación al Home (/main)
      // Esto elimina la pantalla de login actual y cualquier otra cosa de la pila
      Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
    } else {
      // FALLO: Mostramos error
      if (mounted) {
        _mostrarSnackBar(
          authProvider.errorMessage ?? 'Error al iniciar sesión',
          Colors.redAccent,
        );
      }
    }
  }

  void _mostrarSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Future<void> _handleSkip() async {
    // Navegar como invitado
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loginAsGuest();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return _buildTabletLayout(isLoading);
            } else {
              return _buildMobileLayout(isLoading);
            }
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          _buildLogo(),
          const SizedBox(height: 40),
          _buildLoginForm(isLoading),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(bool isLoading) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.grey[900],
            child: Center(child: _buildLogo()),
          ),
        ),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: _buildLoginForm(isLoading),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png',
          height: 120, // Slightly larger
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.directions_car, size: 100, color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildLoginForm(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        // --- EMAIL ---
        _buildLabel('Correo Electrónico'),
        TextField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          keyboardType: TextInputType.emailAddress,
          cursorColor: Colors.red,
          decoration: _buildInputDecoration(
            'usuario@ejemplo.com',
            Icons.email_outlined,
          ),
        ),
        const SizedBox(height: 20),

        // --- PASSWORD ---
        _buildLabel('Contraseña'),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.red,
          decoration: _buildInputDecoration(
            '••••••••',
            Icons.lock_outline,
            isPassword: true,
          ),
        ),

        // --- FORGOT PASSWORD ---
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.pushNamed(context, '/forgot_password'),
            child: const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // --- BUTTON LOGIN ---
        ElevatedButton(
          onPressed: isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Premium Red
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.red.withValues(alpha: 0.5),
            elevation: 8,
            shadowColor: Colors.red.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
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
                  'INICIAR SESIÓN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
        ),

        const SizedBox(height: 30),

        // --- DIVIDER ---
        Row(
          children: const [
            Expanded(child: Divider(color: Colors.white24)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('O', style: TextStyle(color: Colors.white54)),
            ),
            Expanded(child: Divider(color: Colors.white24)),
          ],
        ),

        const SizedBox(height: 30),

        // --- GUEST BUTTON ---
        OutlinedButton(
          onPressed: _handleSkip,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white24),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            'Continuar como Invitado',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),

        const SizedBox(height: 20),

        // --- REGISTER ---
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "¿No tienes cuenta?",
              style: TextStyle(color: Colors.white70),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text(
                'Regístrate',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[700]),
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.grey[900], // Dark input bg
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
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ), // Red focus
      ),
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
    );
  }
}
