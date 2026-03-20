import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/api_services.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/address_model.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});
  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _processOrder();
  }

  Future<void> _processOrder() async {
    // 1. Obtener datos de los argumentos
    await Future.delayed(Duration.zero); // Esperar a que el contexto esté listo
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final List<CartItem> cartItems = args['cartItems'];
    final Address address = args['selectedAddress'];

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final user = authProvider.usuarioActual;

    if (user == null) {
      _showError("Usuario no autenticado");
      return;
    }

    try {
      // 2. Llamada a API (Real)
      final apiService = ApiService();


      await apiService.createOrder(user.id, cartItems, address);

      // 3. Éxito: Limpiar carrito y mostrar éxito
      cartProvider.clearCart();

      if (mounted) {
        setState(() => _isCompleted = true);

        // Esperar un poco para que el usuario vea el check verde
        Timer(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/confirmation',
              arguments: {
                'cartItems': cartItems, // Pasamos para mostrar en ticket
                'selectedAddress': address,
              },
            );
          }
        });
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${message.replaceAll("Exception:", "")}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
    Navigator.pop(context); // Volver atrás
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _isCompleted ? _buildSuccessWidget() : _buildLoadingWidget(),
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Column(
      key: const ValueKey('loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CircularProgressIndicator(color: Colors.white),
        SizedBox(height: 20),
        Text(
          'Procesando Transacción...',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildSuccessWidget() {
    return Column(
      key: const ValueKey('success'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.check_circle, color: Colors.greenAccent, size: 100),
        SizedBox(height: 20),
        Text(
          '¡Pago Aprobado!',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }
}
