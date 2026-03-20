import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    final auth     = Provider.of<AuthProvider>(context, listen: false);
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _snack('Ingresa un correo electrónico válido.', Colors.redAccent);
      return;
    }
    if (password.isEmpty) {
      _snack('Ingresa tu contraseña.', Colors.redAccent);
      return;
    }
    final ok = await auth.login(email, password);
    if (ok && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/main', (_) => false);
    } else if (mounted) {
      _snack(auth.errorMessage ?? 'Error al iniciar sesión', Colors.redAccent);
    }
  }

  Future<void> _handleSkip() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.loginAsGuest();
    if (mounted) Navigator.of(context).pushReplacementNamed('/main');
  }

  void _snack(String msg, Color color) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color),
      );

  @override
  Widget build(BuildContext context) {
    final auth      = Provider.of<AuthProvider>(context);
    final theme     = Theme.of(context);
    final isDark    = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth > 600
              ? _tabletLayout(auth.isLoading, isDark, theme)
              : _mobileLayout(auth.isLoading, isDark, theme),
        ),
      ),
    );
  }

  Widget _mobileLayout(bool loading, bool isDark, ThemeData theme) =>
      SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            _logo(),
            const SizedBox(height: 40),
            _form(loading, isDark, theme),
          ],
        ),
      );

  Widget _tabletLayout(bool loading, bool isDark, ThemeData theme) => Row(
        children: [
          Expanded(
            child: Container(
              color: theme.cardTheme.color,
              child: Center(child: _logo()),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: _form(loading, isDark, theme),
            ),
          ),
        ],
      );

  Widget _logo() => Column(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 120,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.directions_car, size: 100, color: Colors.red),
          ),
        ],
      );

  Widget _form(bool loading, bool isDark, ThemeData theme) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          _label('Correo Electrónico', theme),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Colors.red,
            decoration: _inputDec('usuario@ejemplo.com', Icons.email_outlined),
          ),
          const SizedBox(height: 20),
          _label('Contraseña', theme),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            cursorColor: Colors.red,
            decoration: _inputDec('••••••••', Icons.lock_outline, isPassword: true),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgot_password'),
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: loading ? null : _handleLogin,
            child: loading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Text('INICIAR SESIÓN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          const SizedBox(height: 30),
          Row(children: [
            Expanded(child: Divider(color: theme.dividerColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('O', style: TextStyle(color: theme.textTheme.bodySmall?.color)),
            ),
            Expanded(child: Divider(color: theme.dividerColor)),
          ]),
          const SizedBox(height: 30),
          OutlinedButton(
            onPressed: _handleSkip,
            child: const Text('Continuar como Invitado', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('¿No tienes cuenta?', style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('Regístrate', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ]),
        ],
      );

  Widget _label(String text, ThemeData theme) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 14)),
      );

  InputDecoration _inputDec(String hint, IconData icon, {bool isPassword = false}) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            )
          : null,
    );
  }
}