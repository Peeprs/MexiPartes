import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/address_model.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final List<CartItem> cartItems = arguments['cartItems'];
    final Address selectedAddress = arguments['selectedAddress'];
    final double total = cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    final screenshotController = ScreenshotController();

    Future<void> captureAndShare() async {
      try {
        final Uint8List? imageBytes = await screenshotController.capture();
        if (imageBytes != null) {
          final directory = await getTemporaryDirectory();
          final imagePath = await File(
            '${directory.path}/factura_mexipartes.png',
          ).writeAsBytes(imageBytes);
          await Share.shareXFiles([
            XFile(imagePath.path),
          ], text: '¡Gracias por tu compra en MexiPartes!');
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al compartir: $e')));
      }
    }

    Future<void> captureAndSave() async {
      try {
        final Uint8List? imageBytes = await screenshotController.capture();
        if (imageBytes != null) {
          final directory = await getApplicationDocumentsDirectory();
          final imagePath = '${directory.path}/factura_mexipartes.png';
          await File(imagePath).writeAsBytes(imageBytes);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Factura guardada en tus documentos.'),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Compra Completada',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Screenshot(
                  controller: screenshotController,
                  child: _buildInvoice(
                    context,
                    cartItems,
                    selectedAddress,
                    total,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: captureAndSave,
                          icon: const Icon(Icons.download, color: Colors.white),
                          label: const Text(
                            'Guardar',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: captureAndShare,
                          icon: const Icon(Icons.share, color: Colors.white),
                          label: const Text(
                            'Compartir',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/main', (route) => false);
                      Navigator.of(context).pushNamed('/orders');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Ver Mis Pedidos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoice(
    BuildContext context,
    List<CartItem> items,
    Address address,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFF1C1C1E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/images/logo.png', height: 40),
              const Text(
                'FACTURA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 32),
          const Text(
            'ENVIADO A:',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            '${address.name} ${address.lastNamePaternal}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            '${address.street}, ${address.colony}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          const Text(
            'RESUMEN DEL PEDIDO:',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Column(
            children: items
                .map(
                  (item) => _buildInvoiceItem(
                    item.name,
                    'x${item.quantity}',
                    '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                  ),
                )
                .toList(),
          ),
          const Divider(color: Colors.white24, height: 32),
          _buildTotalRow('Subtotal:', '\$${total.toStringAsFixed(2)}'),
          _buildTotalRow('Envío:', 'Gratis'),
          const SizedBox(height: 8),
          _buildTotalRow(
            'TOTAL:',
            '\$${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: 24),
          const Center(
            child: Icon(Icons.qr_code_2, color: Colors.white, size: 80),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'ID de Pedido: #MXP-12345XYZ',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceItem(String name, String qty, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(name, style: const TextStyle(color: Colors.white)),
          ),
          Text(qty, style: const TextStyle(color: Colors.white70)),
          const SizedBox(width: 16),
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.white70,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.white70,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
