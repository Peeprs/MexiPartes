import 'package:flutter/material.dart';
import '../../models/order_model.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  late OrderModel _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    final status = _currentOrder.status;

    // Colores de estado
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case OrderStatus.processing:
        statusColor = Colors.orange;
        statusText = "Pago Validado - Procesando";
        statusIcon = Icons.inventory_2;
        break;
      case OrderStatus.shipped:
        statusColor = Colors.blue;
        statusText = "En Camino - Repartidor Asignado";
        statusIcon = Icons.local_shipping;
        break;
      case OrderStatus.delivered:
        statusColor = Colors.green;
        statusText = "Entregado - ¡Disfruta tu compra!";
        statusIcon = Icons.check_circle;
        break;
      case OrderStatus.returned:
        statusColor = Colors.red;
        statusText = "Devuelto";
        statusIcon = Icons.assignment_return;
        break;
    }

    return Scaffold(
      backgroundColor: Colors.black, // Dark Theme
      appBar: AppBar(
        title: Text("Pedido #${_currentOrder.id ?? '---'}"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. ESTADO ANIMADO
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Icon(statusIcon, size: 50, color: statusColor),
                  const SizedBox(height: 10),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. DETALLES DEL ENVÍO
            _buildSection(
              title: "Dirección de Entrega",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${_currentOrder.shippingAddress.name} ${_currentOrder.shippingAddress.lastNamePaternal}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${_currentOrder.shippingAddress.street} #${_currentOrder.shippingAddress.extNum} ${_currentOrder.shippingAddress.intNum ?? ''}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "${_currentOrder.shippingAddress.colony}, ${_currentOrder.shippingAddress.postalCode}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    _currentOrder.shippingAddress.phone,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. TICKET DIGITAL (PRODUCTOS)
            _buildSection(
              title: "Ticket Digital",
              child: Column(
                children: [
                  ..._currentOrder.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          // Cantidad
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${item.quantity}x",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Nombre
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "\$${item.price}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          // Total item
                          Text(
                            "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: Colors.grey),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TOTAL",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "\$${_currentOrder.total.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Botón VOLVER
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[900],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "Volver a mis compras",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
