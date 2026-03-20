import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importamos el Provider y las pantallas
import '../../../providers/auth_provider.dart';
import 'login_screen.dart';
// import '../../home/main_screen.dart';
import '../../home/main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Conectamos con el Provider
    final authProvider = Provider.of<AuthProvider>(context);

    // 2. Si se está inicializando (leyendo SharedPreferences), mostramos carga
    if (authProvider.isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }

    // 3. LÓGICA DE NAVEGACIÓN:
    if (authProvider.isAuthenticated) {
      return const MainScreen();
    } else {
      return const LoginScreen();
    }
  }
}
