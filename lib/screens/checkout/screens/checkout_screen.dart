import 'package:flutter/material.dart';
import '../../../models/cart_item_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPaymentIndex = -1;

  void _selectPayment(int index) {
    setState(() {
      if (_selectedPaymentIndex == index) {
        _selectedPaymentIndex = -1;
      } else {
        _selectedPaymentIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Recibimos los items del carrito desde la pantalla anterior
    final cartItems =
        ModalRoute.of(context)!.settings.arguments as List<CartItem>;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Método de Pago',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: _selectedPaymentIndex != -1
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Pasamos los items del carrito a la siguiente pantalla
                  Navigator.pushNamed(
                    context,
                    '/address_selection',
                    arguments: cartItems,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continuar a la Dirección',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPaymentOption(
              index: 0,
              icon: Icons.credit_card,
              title: 'Tarjeta de Crédito/Débito',
              onTap: () => _selectPayment(0),
            ),
            if (_selectedPaymentIndex == 0) _buildCardForm(),
            _buildPaymentOption(
              index: 1,
              icon: Icons.paypal,
              title: 'PayPal',
              onTap: () => _selectPayment(1),
            ),
            _buildPaymentOption(
              index: 2,
              icon: Icons.store,
              title: 'Mercado Pago',
              onTap: () => _selectPayment(2),
            ),
            _buildPaymentOption(
              index: 3,
              icon: Icons.local_convenience_store,
              title: 'Transferencia por OXXO',
              onTap: () => _selectPayment(3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required int index,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final isSelected = _selectedPaymentIndex == index;
    return Card(
      color: isSelected ? const Color(0xFF2C2C2E) : Colors.grey[900],
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.white : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.greenAccent)
            : null,
      ),
    );
  }

  Widget _buildCardForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Número de Tarjeta',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
